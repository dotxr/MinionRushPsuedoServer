package android.content;
public abstract class Context {
    public abstract java.io.File getFilesDir();
    public abstract java.io.File getExternalFilesDir(String type);
    public abstract String getPackageName();
}
