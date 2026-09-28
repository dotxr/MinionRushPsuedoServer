package com.google.android.play.core.assetpacks;

import android.content.Context;
import com.google.android.play.core.tasks.Task;
import com.google.android.play.core.tasks.Tasks;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class RevivalPacks implements AssetPackManager {
    static final String BASE = "@BASE@";
    static final int PENDING = 1, DOWNLOADING = 2, COMPLETED = 4, FAILED = 5, NOT_INSTALLED = 8;

    final File root, dlcs;
    final List<AssetPackStateUpdateListener> listeners = new CopyOnWriteArrayList<>();
    final Map<String, long[]> progress = new ConcurrentHashMap<>();
    final Map<String, String> owner = new ConcurrentHashMap<>();
    final Set<String> scanned = Collections.newSetFromMap(new ConcurrentHashMap<>());
    final Map<String, Long> checked = new ConcurrentHashMap<>();

    static RevivalPacks instance;

    public static synchronized RevivalPacks get(Context c) {
        if (instance == null) instance = new RevivalPacks(c);
        return instance;
    }

    static int portOff;
    static final String[] PREFETCH = {"dlc_1_mandatory_common", "dlc_2_recommend", "dlc_2_recommend_rooms", "dlc_uiart_2_scrapbook"};
    static boolean readsFirst;

    static int portOffset(String pkg) {
        return pkg.contains("MinionRush961") ? 0 : pkg.contains("MinionRushLegacy") ? 10 : pkg.contains("MinionRush730") ? 20 : 30;
    }

    static String local(String url) {
        if (portOff == 0) return url;
        return url.replace("127.0.0.1:1808/", "127.0.0.1:" + (1808 + portOff) + "/")
                  .replace("127.0.0.1:18080/", "127.0.0.1:" + (18080 + portOff) + "/");
    }

    public RevivalPacks(Context c) {
        portOff = portOffset(c.getPackageName());
        readsFirst = c.getPackageName().contains("MinionRush730");
        root = new File(c.getFilesDir(), "revival_packs");
        dlcs = new File(c.getExternalFilesDir(null), "dlcs_1");
        Thread t = new Thread(() -> {
            for (int i = 0; i < 20; i++) {
                scanGroups();
                String[] names = root.list();
                if (names != null) for (String p : names) if (ready(p)) { checked.remove(p); ensureJpks(p); }
                try { Thread.sleep(15000); } catch (InterruptedException e) { return; }
            }
        }, "revival-packs-jpk");
        t.setDaemon(true);
        t.start();
        if (!readsFirst) {
            Thread f = new Thread(() -> { for (String p : PREFETCH) fetchNow(p); }, "revival-packs-prefetch");
            f.setDaemon(true);
            f.start();
        }
    }

    File dir(String p) { return new File(root, p); }

    boolean ready(String p) { return new File(dir(p), ".done").exists(); }

    static String key(String part) {
        String n = part.substring(part.lastIndexOf('/') + 1);
        for (String pl : new String[]{"_amazon_", "_android_", "_ios_"}) {
            int i = n.indexOf(pl);
            if (i > 0) return n.substring(0, i);
        }
        return null;
    }

    List<String> partList(String p) throws IOException {
        List<String> parts = new ArrayList<>();
        try (BufferedReader r = new BufferedReader(new InputStreamReader(open(BASE + p).getInputStream()))) {
            for (String l; (l = r.readLine()) != null; ) if (!l.trim().isEmpty()) parts.add(l.trim());
        }
        return parts;
    }

    void scanGroups() {
        String[] names = root.list();
        if (names == null) return;
        for (String g : names) {
            if (scanned.contains(g) || !ready(g)) continue;
            File list = new File(dir(g), ".parts");
            try {
                if (!list.exists() || list.length() == 0 || !new File(dir(g), ".jpk").exists()) {
                    deleteTree(dir(g));
                    continue;
                }
                Set<String> keys = new HashSet<>();
                try (BufferedReader r = new BufferedReader(new FileReader(list))) {
                    for (String l; (l = r.readLine()) != null; ) { String k = key(l); if (k != null) keys.add(k); }
                }
                if (keys.size() > 1) for (String k : keys) {
                    owner.putIfAbsent(k, g);
                    owner.putIfAbsent(k.replaceAll("_\\d+$", ""), g);
                }
                scanned.add(g);
            } catch (IOException ignored) {
            }
        }
    }

    String home(String p) {
        String h = ready(p) ? p : null;
        if (h == null) {
            scanGroups();
            String g = owner.get(p);
            h = g != null && ready(g) ? g : null;
        }
        if (h != null) ensureJpks(h);
        return h;
    }

    void ensureJpks(String h) {
        long now = System.currentTimeMillis();
        Long last = checked.get(h);
        if (last != null && now - last < 10000) return;
        checked.put(h, now);
        File list = new File(dir(h), ".parts");
        byte[] buf = new byte[1 << 16];
        try (BufferedReader r = new BufferedReader(new FileReader(list))) {
            dlcs.mkdirs();
            for (String url; (url = r.readLine()) != null; ) {
                if (url.isEmpty()) continue;
                File jpk = new File(dlcs, url.substring(url.lastIndexOf('/') + 1) + ".jpk");
                if (jpk.exists()) continue;
                File part = new File(jpk.getPath() + ".part");
                try (InputStream in = open(url).getInputStream(); OutputStream o = new FileOutputStream(part)) {
                    for (int n; (n = in.read(buf)) > 0; ) o.write(buf, 0, n);
                }
                part.renameTo(jpk);
            }
        } catch (IOException ignored) {
        }
    }

    AssetPackState state(String p) {
        String h = home(p);
        if (h != null) {
            long n = new File(dir(h), ".done").length();
            return AssetPackState.a(p, COMPLETED, 0, n, n, 1.0);
        }
        long[] s = progress.get(p);
        if (s == null) return AssetPackState.a(p, NOT_INSTALLED, 0, 0, 0, 0);
        return AssetPackState.a(p, (int) s[0], 0, s[1], s[2], s[2] > 0 ? (double) s[1] / s[2] : 0);
    }

    AssetPackStates states(List<String> packs) {
        Map<String, AssetPackState> m = new HashMap<>();
        long total = 0;
        for (String p : packs) {
            AssetPackState s = state(p);
            m.put(p, s);
            long[] v = progress.get(p);
            if (v != null) total += v[2];
        }
        return AssetPackStates.a(total, m);
    }

    void publish(String p) {
        AssetPackState s = state(p);
        for (AssetPackStateUpdateListener l : listeners) l.onStateUpdate(s);
    }

    static HttpURLConnection open(String url) throws IOException {
        HttpURLConnection c = (HttpURLConnection) new URL(local(url)).openConnection();
        c.setInstanceFollowRedirects(true);
        c.setConnectTimeout(30000);
        c.setReadTimeout(60000);
        if (c.getResponseCode() != 200) throw new IOException("HTTP " + c.getResponseCode() + " " + url);
        return c;
    }

    void download(String p) {
        long[] s = progress.get(p);
        try {
            List<String> parts = partList(p);
            if (parts.isEmpty()) throw new IOException("no parts for " + p);
            File tmp = new File(root, p + ".tmp");
            deleteTree(tmp);
            File assets = new File(tmp, "assets");
            assets.mkdirs();
            s[0] = DOWNLOADING;
            byte[] buf = new byte[1 << 16];
            long last = 0;
            for (String url : parts) {
                IOException err = null;
                for (int attempt = 0; attempt < 4; attempt++) {
                    long before = s[1];
                    try {
                        HttpURLConnection c = open(url);
                        if (attempt == 0) s[2] += Math.max(0, c.getContentLengthLong());
                        publish(p);
                        dlcs.mkdirs();
                        File jpk = new File(dlcs, url.substring(url.lastIndexOf('/') + 1) + ".jpk"), part = new File(jpk.getPath() + ".part");
                        try (CountingStream in = new CountingStream(c.getInputStream(), s); OutputStream o = new FileOutputStream(part)) {
                            for (int n; (n = in.read(buf)) > 0; ) {
                                o.write(buf, 0, n);
                                if (s[1] - last > (1 << 20)) { last = s[1]; publish(p); }
                            }
                        }
                        try (ZipInputStream z = new ZipInputStream(new BufferedInputStream(new FileInputStream(part), 1 << 16))) {
                            for (ZipEntry e; (e = z.getNextEntry()) != null; ) {
                                File f = new File(assets, e.getName());
                                if (!f.getCanonicalPath().startsWith(assets.getCanonicalPath())) continue;
                                if (e.isDirectory()) { f.mkdirs(); continue; }
                                f.getParentFile().mkdirs();
                                try (OutputStream o = new FileOutputStream(f)) {
                                    for (int n; (n = z.read(buf)) > 0; ) o.write(buf, 0, n);
                                }
                            }
                        }
                        if (!part.renameTo(jpk)) throw new IOException("rename " + jpk);
                        err = null;
                        break;
                    } catch (IOException e) {
                        err = e;
                        s[1] = before;
                        try { Thread.sleep(2000L << attempt); } catch (InterruptedException ignored) { }
                    }
                }
                if (err != null) throw err;
            }
            try (Writer w = new FileWriter(new File(tmp, ".parts"))) { for (String u : parts) w.write(u + "\n"); }
            new File(tmp, ".jpk").createNewFile();
            deleteTree(dir(p));
            if (!tmp.renameTo(dir(p))) throw new IOException("rename");
            try (Writer w = new FileWriter(new File(dir(p), ".done"))) { w.write(String.valueOf(s[1])); }
            s[0] = COMPLETED;
        } catch (Exception e) {
            s[0] = FAILED;
        }
        publish(p);
    }

    synchronized void fetchNow(String p) {
        if (home(p) != null) return;
        long[] s = progress.get(p);
        if (s != null && s[0] != FAILED && s[0] != COMPLETED) return;
        root.mkdirs();
        progress.put(p, new long[]{PENDING, 0, 0});
        download(p);
    }

    static void deleteTree(File f) {
        File[] kids = f.listFiles();
        if (kids != null) for (File k : kids) deleteTree(k);
        f.delete();
    }

    @Override public Task<AssetPackStates> fetch(List<String> packs) {
        root.mkdirs();
        for (String p : packs) {
            if (home(p) != null) continue;
            long[] s = progress.get(p);
            if (s != null && (s[0] == PENDING || s[0] == DOWNLOADING)) continue;
            progress.put(p, new long[]{PENDING, 0, 0});
            new Thread(() -> download(p), "revival-pack-" + p).start();
        }
        return Tasks.a(states(packs));
    }

    @Override public Task<AssetPackStates> getPackStates(List<String> packs) { return Tasks.a(states(packs)); }

    AssetPackLocation location(String h) {
        return AssetPackLocation.a(dir(h).getPath(), new File(dir(h), "assets").getPath());
    }

    @Override public AssetPackLocation getPackLocation(String p) {
        String h = home(p);
        if (h == null && readsFirst) { fetchNow(p); h = home(p); }
        return h != null ? location(h) : null;
    }

    @Override public Map<String, AssetPackLocation> getPackLocations() {
        Map<String, AssetPackLocation> m = new HashMap<>();
        scanGroups();
        for (Map.Entry<String, String> e : owner.entrySet()) if (ready(e.getValue())) m.put(e.getKey(), location(e.getValue()));
        String[] names = root.list();
        if (names != null) for (String p : names) if (ready(p)) m.put(p, location(p));
        return m;
    }

    @Override public AssetLocation getAssetLocation(String p, String a) {
        String h = home(p);
        if (h == null) return null;
        File f = new File(new File(dir(h), "assets"), a);
        return f.exists() ? AssetLocation.a(f.getPath(), 0, f.length()) : null;
    }

    @Override public AssetPackStates cancel(List<String> packs) { return states(packs); }

    @Override public void registerListener(AssetPackStateUpdateListener l) { listeners.add(l); }

    @Override public void unregisterListener(AssetPackStateUpdateListener l) { listeners.remove(l); }

    @Override public void clearListeners() { listeners.clear(); }

    @Override public Task<Void> removePack(String p) {
        deleteTree(dir(p));
        progress.remove(p);
        return Tasks.a(null);
    }

    @Override public Task<Integer> showCellularDataConfirmation(android.app.Activity a) { return Tasks.a(-1); }

    static class CountingStream extends FilterInputStream {
        final long[] s;
        CountingStream(InputStream in, long[] s) { super(in); this.s = s; }
        @Override public int read() throws IOException { int b = super.read(); if (b >= 0) s[1]++; return b; }
        @Override public int read(byte[] b, int o, int n) throws IOException { int r = super.read(b, o, n); if (r > 0) s[1] += r; return r; }
    }
}
