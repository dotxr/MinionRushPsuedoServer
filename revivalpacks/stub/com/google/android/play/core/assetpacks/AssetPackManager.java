package com.google.android.play.core.assetpacks;
import com.google.android.play.core.tasks.Task;
import java.util.*;
public interface AssetPackManager {
  AssetPackStates cancel(List<String> p);
  void clearListeners();
  Task<AssetPackStates> fetch(List<String> p);
  AssetLocation getAssetLocation(String p, String a);
  AssetPackLocation getPackLocation(String p);
  Map<String, AssetPackLocation> getPackLocations();
  Task<AssetPackStates> getPackStates(List<String> p);
  void registerListener(AssetPackStateUpdateListener l);
  Task<Void> removePack(String p);
  Task<Integer> showCellularDataConfirmation(android.app.Activity a);
  void unregisterListener(AssetPackStateUpdateListener l);
}
