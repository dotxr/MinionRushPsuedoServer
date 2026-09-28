.class public Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;
.super Ljava/lang/Object;
.source "GameAPIAndroidGLSocialLib.java"

.implements Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$GameHelperListener;

.field public static final CLIENT_GAMES:I = 0x1

.field public static final FAILED_SIGN_IN:I = 0x2329

.field public static final OPEN_BROWSER:I = 0x3ee

.field public static final POST_ON_PAGE:I = 0x3ec

.field public static final RC_UNUSED:I = 0x232a

.field public static final REQUEST_ACHIEVEMENTS:I = 0x3e9

.field public static final REQUEST_LEADEARBOARD:I = 0x3ea

.field private static isAvatarRequest:Z

.field public static isLogged:Z

.field private static mAchievementManager:Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;

.field private static mGameActivity:Landroid/app/Activity;

.field protected static mHelper:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

.field private static mLeadearboardManager:Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;

.field private static mRawData:[B

.field protected static mRequestedClients:I

.field private static sAuthRequestIsCalling:Z

.field private static sInitRequestIsCalling:Z

.field private static sIsConnectingOnResume:Z

.field private static sLoginRequestIsCalling:Z

.field public static s_instance:Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;

.field private static s_userData:Lorg/json/JSONArray;

.method static constructor <clinit>()V
    .locals 0

    return-void
.end method

.method public constructor <init>(Landroid/app/Activity;Landroid/view/ViewGroup;)V
    .locals 0

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const-string p2, "Google: GameAPIAndroidGLSocialLib constructor"

    .line 2
    invoke-static {p2}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 3
    sput-object p1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mGameActivity:Landroid/app/Activity;

    .line 4
    sput-object p0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->s_instance:Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;

    return-void
.end method

.method public static ConnectToService()V
    .locals 0

    return-void
.end method

.method public static DisconnectFromService()V
    .locals 2

    const-string v0, "Signing out!!"

    .line 1
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 2
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mGameActivity:Landroid/app/Activity;

    new-instance v1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib$3;

    invoke-direct {v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib$3;-><init>()V

    invoke-virtual {v0, v1}, Landroid/app/Activity;->runOnUiThread(Ljava/lang/Runnable;)V

    return-void
.end method

.method private static DisconnectGamesClient()V
    .locals 2

    .line 1
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->removeClient(I)V

    .line 2
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->DisconnectFromService()V

    .line 3
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v0

    invoke-virtual {v0, v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->addClient(I)V

    const/4 v0, 0x0

    const-string v1, ""

    .line 4
    invoke-static {v0, v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPINotifyAuthChanges(ZLjava/lang/String;)V

    return-void
.end method

.method public static GetAccessToken()Ljava/lang/String;
    .locals 1

    const-string v0, "GetAccessToken is no loger available for Game API, please use GetAuthorizationCode"

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const-string v0, ""

    return-object v0
.end method

.method public static GetAuthorizationToken()V
    .locals 3

    const-string v0, "GetAuthorizationToken"

    .line 1
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 2
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->IsLoggedIn()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->HasClient(I)Z

    move-result v0

    if-nez v0, :cond_0

    goto :goto_1

    .line 3
    :cond_0
    :try_start_0
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v0

    invoke-virtual {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->getApiClient()Lcom/google/android/gms/common/api/GoogleApiClient;

    move-result-object v0

    sget-object v1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mGameActivity:Landroid/app/Activity;

    const v2, 0x7f1301d7

    invoke-virtual {v1, v2}, Landroid/app/Activity;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/google/android/gms/games/Games;->getGamesServerAuthCode(Lcom/google/android/gms/common/api/GoogleApiClient;Ljava/lang/String;)Lcom/google/android/gms/common/api/PendingResult;

    move-result-object v0

    .line 4
    new-instance v1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib$6;

    invoke-direct {v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib$6;-><init>()V

    invoke-virtual {v0, v1}, Lcom/google/android/gms/common/api/PendingResult;->setResultCallback(Lcom/google/android/gms/common/api/ResultCallback;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 5
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Not logged in! Exception: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    .line 6
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->DisconnectGamesClient()V

    :goto_0
    return-void

    :cond_1
    :goto_1
    const-string v0, "Authorization Code cannot be retrieved!"

    .line 7
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    return-void
.end method

.method public static GetFirstName()V
    .locals 1

    const-string v0, "no first name on client_games"

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    return-void
.end method

.method public static GetFriends(Ljava/lang/String;)V
    .locals 0

    const-string p0, "GetFriends not available for CLIENT_GAMES"

    invoke-static {p0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    return-void
.end method

.method public static GetFriendsData(ZZII)V
    .locals 0

    const-string p0, "GetFriendsData not available for CLIENT_GAMES"

    invoke-static {p0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    return-void
.end method

.method public static GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;
    .locals 2

    .line 1
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mHelper:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    if-nez v0, :cond_0

    const-string v0, "GameAPIAndroidGLSocialLib create a new GameHelper"

    .line 2
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 3
    new-instance v0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    sget-object v1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mGameActivity:Landroid/app/Activity;

    invoke-direct {v0, v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;-><init>(Landroid/app/Activity;)V

    sput-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mHelper:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    .line 4
    :cond_0
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mHelper:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    return-object v0
.end method

.method public static GetGamerId()V
    .locals 3

    .line 1
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->IsLoggedIn()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->HasClient(I)Z

    move-result v0

    if-nez v0, :cond_0

    goto :goto_0

    .line 2
    :cond_0
    sget-object v0, Lcom/google/android/gms/games/Games;->Players:Lcom/google/android/gms/games/Players;

    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v1

    invoke-virtual {v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->getApiClient()Lcom/google/android/gms/common/api/GoogleApiClient;

    move-result-object v1

    invoke-interface {v0, v1}, Lcom/google/android/gms/games/Players;->getCurrentPlayerId(Lcom/google/android/gms/common/api/GoogleApiClient;)Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x0

    sget-object v2, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mRawData:[B

    invoke-static {v0, v1, v2}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPICompleteWithData(Ljava/lang/String;Z[B)V

    return-void

    :cond_1
    :goto_0
    const-string v0, "GamerId cannot be retrieved!"

    .line 3
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    return-void
.end method

.method public static GetPlayerAvatar()V
    .locals 3

    :try_start_0
    const-string v0, "GameAPIAndroidGLSocialLib.java GetPlayerAvatar"

    .line 1
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const/4 v0, 0x1

    .line 2
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->HasClient(I)Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v0, "GameAPIAndroidGLSocialLib.java GetCurrentPlayer"

    .line 3
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 4
    sget-object v0, Lcom/google/android/gms/games/Games;->Players:Lcom/google/android/gms/games/Players;

    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v1

    invoke-virtual {v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->getApiClient()Lcom/google/android/gms/common/api/GoogleApiClient;

    move-result-object v1

    invoke-interface {v0, v1}, Lcom/google/android/gms/games/Players;->getCurrentPlayer(Lcom/google/android/gms/common/api/GoogleApiClient;)Lcom/google/android/gms/games/Player;

    move-result-object v0

    if-nez v0, :cond_0

    const-string v0, "No player was retrieved"

    .line 5
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    return-void

    .line 6
    :cond_0
    invoke-interface {v0}, Lcom/google/android/gms/games/Player;->hasIconImage()Z

    move-result v1

    if-eqz v1, :cond_1

    .line 7
    invoke-interface {v0}, Lcom/google/android/gms/games/Player;->getIconImageUrl()Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x0

    sget-object v2, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mRawData:[B

    invoke-static {v0, v1, v2}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPICompleteWithData(Ljava/lang/String;Z[B)V

    goto :goto_0

    :cond_1
    const-string v0, "The User\'s games profile has no image "

    .line 8
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    goto :goto_0

    :cond_2
    const-string v0, "No Game Client & No Plus Client connected"

    .line 9
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 10
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Not logged in! Exception: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method public static GetPlayerName()V
    .locals 3

    .line 1
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->IsLoggedIn()Z

    move-result v0

    if-eqz v0, :cond_2

    const/4 v0, 0x1

    .line 2
    :try_start_0
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->HasClient(I)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 3
    sget-object v0, Lcom/google/android/gms/games/Games;->Players:Lcom/google/android/gms/games/Players;

    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v1

    invoke-virtual {v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->getApiClient()Lcom/google/android/gms/common/api/GoogleApiClient;

    move-result-object v1

    invoke-interface {v0, v1}, Lcom/google/android/gms/games/Players;->getCurrentPlayer(Lcom/google/android/gms/common/api/GoogleApiClient;)Lcom/google/android/gms/games/Player;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 4
    invoke-interface {v0}, Lcom/google/android/gms/games/Player;->getDisplayName()Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x0

    sget-object v2, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mRawData:[B

    invoke-static {v0, v1, v2}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPICompleteWithData(Ljava/lang/String;Z[B)V

    goto :goto_0

    :cond_0
    const-string v0, "No player could be retrieved\n"

    .line 5
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    goto :goto_0

    :cond_1
    const-string v0, "No Game Client & No Plus Client connected"

    .line 6
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 7
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Exception raised when attempting to retrieve user name: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    goto :goto_0

    :cond_2
    const-string v0, "Not logged in!"

    .line 8
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method public static GetUid()Ljava/lang/String;
    .locals 3

    .line 1
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->IsLoggedIn()Z

    move-result v0

    const-string v1, ""

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    .line 2
    :try_start_0
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->HasClient(I)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 3
    sget-object v0, Lcom/google/android/gms/games/Games;->Players:Lcom/google/android/gms/games/Players;

    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v2

    invoke-virtual {v2}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->getApiClient()Lcom/google/android/gms/common/api/GoogleApiClient;

    move-result-object v2

    invoke-interface {v0, v2}, Lcom/google/android/gms/games/Players;->getCurrentPlayerId(Lcom/google/android/gms/common/api/GoogleApiClient;)Ljava/lang/String;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    :catch_0
    :cond_0
    return-object v1
.end method

.method public static GetUserData(Ljava/lang/String;)V
    .locals 0

    const-string p0, "GetUserData not available for CLIENT_GAMES"

    invoke-static {p0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    return-void
.end method

.method public static HasClient(I)Z
    .locals 1

    sget v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mRequestedClients:I

    and-int/2addr p0, v0

    if-eqz p0, :cond_0

    const/4 p0, 0x1

    goto :goto_0

    :cond_0
    const/4 p0, 0x0

    :goto_0
    return p0
.end method

.method public static IncrementAchievement(Ljava/lang/String;I)V
    .locals 1

    .line 1
    :try_start_0
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mAchievementManager:Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;

    invoke-virtual {v0, p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;->incrementAchievement(Ljava/lang/String;I)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception p0

    .line 2
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "Not logged in! Exception: "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method public static InitGameAPI(ZZ)V
    .locals 1

    const-string p0, "Setting up Game Services & Plus Client"

    .line 1
    invoke-static {p0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 2
    sget-object p0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mGameActivity:Landroid/app/Activity;

    new-instance v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib$2;

    invoke-direct {v0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib$2;-><init>(Z)V

    invoke-virtual {p0, v0}, Landroid/app/Activity;->runOnUiThread(Ljava/lang/Runnable;)V

    return-void
.end method

.method public static IsLoggedIn()Z
    .locals 1

    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mHelper:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->isSignedIn()Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public static PostPhotoToWall(Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    const-string p0, "postPhotoToWall() not available for CLIENT_GAMES"

    .line 1
    invoke-static {p0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Info(Ljava/lang/String;)V

    const-string p0, "PostPhotoToWall"

    .line 2
    invoke-static {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    return-void
.end method

.method public static PostToWall(Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    const-string p0, "postToWall() not available for CLIENT_GAMES"

    invoke-static {p0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Info(Ljava/lang/String;)V

    return-void
.end method

.method public static ResetAchievements()V
    .locals 3

    .line 1
    :try_start_0
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mAchievementManager:Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;

    const-string v1, "all"

    sget-object v2, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mGameActivity:Landroid/app/Activity;

    invoke-virtual {v0, v1, v2}, Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;->resetAchievement(Ljava/lang/String;Landroid/content/Context;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Not logged in! Exception: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method public static SetRequestedClients(I)V
    .locals 0

    sput p0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mRequestedClients:I

    return-void
.end method

.method public static ShowAchievements()V
    .locals 3

    .line 1
    :try_start_0
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mAchievementManager:Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;

    invoke-virtual {v0}, Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;->showAchievements()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Not logged in! Exception: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method public static ShowAllLeadearboards()V
    .locals 3

    .line 1
    :try_start_0
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mLeadearboardManager:Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;

    invoke-virtual {v0}, Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;->showAllLeadearboards()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Not logged in! Exception: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method public static ShowLeadearboardWithId(Ljava/lang/String;)V
    .locals 2

    .line 1
    :try_start_0
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mLeadearboardManager:Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;

    invoke-virtual {v0, p0}, Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;->ShowLeadearboard(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception p0

    .line 2
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Not logged in! Exception: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method public static SubmitScore(Ljava/lang/String;I)V
    .locals 1

    .line 1
    :try_start_0
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mLeadearboardManager:Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;

    invoke-virtual {v0, p1, p0}, Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;->submitScore(ILjava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception p0

    .line 2
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "Not logged in! Exception: "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method public static TryAutoConnectToService()V
    .locals 0

    return-void
.end method

.method public static UnlockAchievement(Ljava/lang/String;)V
    .locals 2

    .line 1
    :try_start_0
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mAchievementManager:Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;

    invoke-virtual {v0, p0}, Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;->unlockAchievement(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception p0

    .line 2
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Not logged in! Exception: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, " "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method static synthetic access$000()Z
    .locals 1

    sget-boolean v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sLoginRequestIsCalling:Z

    return v0
.end method

.method static synthetic access$002(Z)Z
    .locals 0

    sput-boolean p0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sLoginRequestIsCalling:Z

    return p0
.end method

.method static synthetic access$100()V
    .locals 0

    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->DisconnectGamesClient()V

    return-void
.end method

.method static synthetic access$202(Z)Z
    .locals 0

    sput-boolean p0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sInitRequestIsCalling:Z

    return p0
.end method

.method static synthetic access$302(Z)Z
    .locals 0

    sput-boolean p0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sAuthRequestIsCalling:Z

    return p0
.end method

.method static synthetic access$400()Landroid/app/Activity;
    .locals 1

    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mGameActivity:Landroid/app/Activity;

    return-object v0
.end method

.method static synthetic access$502(Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;)Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;
    .locals 0

    sput-object p0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mAchievementManager:Lcom/gameloft/GLSocialLib/GameAPI/AchievementManager;

    return-object p0
.end method

.method static synthetic access$602(Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;)Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;
    .locals 0

    sput-object p0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mLeadearboardManager:Lcom/gameloft/GLSocialLib/GameAPI/LeadearboardManager;

    return-object p0
.end method

.method static synthetic access$700()[B
    .locals 1

    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mRawData:[B

    return-object v0
.end method

.method public static native nativeGameAPIComplete()V
.end method

.method public static native nativeGameAPICompleteWithData(Ljava/lang/String;Z[B)V
.end method

.method public static native nativeGameAPIDidNotComplete(Ljava/lang/String;)V
.end method

.method public static native nativeGameAPINotifyAuthChanges(ZLjava/lang/String;)V
.end method

.method public static native nativeGameAPISetCanceled()V
.end method

.method public static native nativeInit()V
.end method

.method public static sendGameRequestToFriends(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    const-string p0, "sendGameRequestToFriends not available for CLIENT_GAMES"

    invoke-static {p0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Info(Ljava/lang/String;)V

    return-void
.end method

.method public SetData([B)V
    .locals 0

    sput-object p1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mRawData:[B

    return-void
.end method

.method public getGameActivity()Landroid/app/Activity;
    .locals 1

    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mGameActivity:Landroid/app/Activity;

    return-object v0
.end method

.method public onActivityResult(IILandroid/content/Intent;)V
    .locals 3

    .line 1
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Google: onActivityResult() requestCode="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " and resultCode="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const/16 v0, 0x3e9

    if-eq p1, v0, :cond_c

    const/16 v0, 0x3ea

    if-eq p1, v0, :cond_c

    const/16 v0, 0x3ec

    const/4 v1, -0x1

    if-eq p1, v0, :cond_6

    const/16 v0, 0x3ee

    const-string v2, "Google: mHelper is null"

    if-eq p1, v0, :cond_2

    const/16 v0, 0x2329

    if-eq p1, v0, :cond_0

    goto/16 :goto_1

    .line 2
    :cond_0
    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mHelper:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    if-nez v0, :cond_1

    .line 3
    invoke-static {v2}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    goto :goto_0

    .line 4
    :cond_1
    invoke-virtual {v0, p1, p2, p3}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->onActivityResult(IILandroid/content/Intent;)V

    :goto_0
    if-nez p2, :cond_d

    .line 5
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPISetCanceled()V

    goto/16 :goto_1

    .line 6
    :cond_2
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string p3, "OPEN_BROWSER: resultCode="

    invoke-virtual {p1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 7
    sget-object p1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mHelper:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    if-nez p1, :cond_3

    .line 8
    invoke-static {v2}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 9
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->onSignInFailed()V

    goto :goto_1

    .line 10
    :cond_3
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object p1

    invoke-virtual {p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->isGooglePlayServicesAvailable()I

    move-result p1

    if-eqz p1, :cond_5

    .line 11
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->IsLoggedIn()Z

    move-result p1

    if-eqz p1, :cond_4

    if-ne p2, v1, :cond_4

    .line 12
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->onSignInSucceeded()V

    goto :goto_1

    .line 13
    :cond_4
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->onSignInFailed()V

    goto :goto_1

    .line 14
    :cond_5
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->ConnectToService()V

    goto :goto_1

    :cond_6
    if-ne p2, v1, :cond_7

    .line 15
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIComplete()V

    goto :goto_1

    :cond_7
    if-eqz p2, :cond_b

    const/16 p1, 0x2712

    if-eq p2, p1, :cond_a

    const/16 p1, 0x2716

    if-eq p2, p1, :cond_9

    const/16 p1, 0x2717

    if-eq p2, p1, :cond_8

    const-string p1, "UNKNOWN_ERROR!"

    .line 16
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    goto :goto_1

    :cond_8
    const-string p1, "RESULT_SEND_REQUEST_FAILED!"

    .line 17
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    goto :goto_1

    :cond_9
    const-string p1, "RESULT_NETWORK_FAILURE!"

    .line 18
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    goto :goto_1

    :cond_a
    const-string p1, "RESULT_SIGN_IN_FAILED!"

    .line 19
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    goto :goto_1

    .line 20
    :cond_b
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPISetCanceled()V

    const-string p1, "USER CANCELED!"

    .line 21
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    goto :goto_1

    .line 22
    :cond_c
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIComplete()V

    const/16 p1, 0x2711

    if-ne p2, p1, :cond_d

    .line 23
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->DisconnectGamesClient()V

    :cond_d
    :goto_1
    return-void
.end method

.method public onResume()V
    .locals 2

    sget-object v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->mGameActivity:Landroid/app/Activity;

    new-instance v1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib$1;

    invoke-direct {v1, p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib$1;-><init>(Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;)V

    invoke-virtual {v0, v1}, Landroid/app/Activity;->runOnUiThread(Ljava/lang/Runnable;)V

    return-void
.end method

.method public onSignInFailed()V
    .locals 2

    const/4 v0, 0x0

    .line 1
    sput-boolean v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sAuthRequestIsCalling:Z

    const-string v1, "onSignInFailed"

    .line 2
    invoke-static {v1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 3
    sget-boolean v1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sInitRequestIsCalling:Z

    if-eqz v1, :cond_2

    .line 4
    sput-boolean v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sInitRequestIsCalling:Z

    .line 5
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v0

    invoke-virtual {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->hasSignInError()Z

    move-result v0

    const/4 v1, 0x1

    if-eqz v0, :cond_0

    .line 6
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v0

    invoke-virtual {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->getSignInError()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    move-result-object v0

    .line 7
    invoke-virtual {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPINotifyAuthChanges(ZLjava/lang/String;)V

    goto :goto_0

    .line 8
    :cond_0
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->GetGameHelper()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;

    move-result-object v0

    invoke-virtual {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->IsSignInCancelled()Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "USER CANCELED!"

    .line 9
    invoke-static {v1, v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPINotifyAuthChanges(ZLjava/lang/String;)V

    .line 10
    :cond_1
    :goto_0
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIComplete()V

    goto :goto_1

    .line 11
    :cond_2
    sget-boolean v1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sIsConnectingOnResume:Z

    if-nez v1, :cond_3

    .line 12
    sput-boolean v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sLoginRequestIsCalling:Z

    const-string v0, "Sign In Failed!"

    .line 13
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIDidNotComplete(Ljava/lang/String;)V

    goto :goto_1

    .line 14
    :cond_3
    sput-boolean v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sIsConnectingOnResume:Z

    :goto_1
    return-void
.end method

.method public onSignInSucceeded()V
    .locals 2

    const/4 v0, 0x0

    .line 1
    sput-boolean v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sAuthRequestIsCalling:Z

    const-string v1, "onSignInSucceeded"

    .line 2
    invoke-static {v1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 3
    sget-boolean v1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sInitRequestIsCalling:Z

    if-eqz v1, :cond_0

    .line 4
    sput-boolean v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sInitRequestIsCalling:Z

    const/4 v0, 0x1

    const-string v1, ""

    .line 5
    invoke-static {v0, v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPINotifyAuthChanges(ZLjava/lang/String;)V

    .line 6
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIComplete()V

    goto :goto_0

    .line 7
    :cond_0
    sget-boolean v1, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sIsConnectingOnResume:Z

    if-nez v1, :cond_1

    .line 8
    sput-boolean v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sLoginRequestIsCalling:Z

    .line 9
    invoke-static {}, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->nativeGameAPIComplete()V

    goto :goto_0

    .line 10
    :cond_1
    sput-boolean v0, Lcom/gameloft/GLSocialLib/GameAPI/GameAPIAndroidGLSocialLib;->sIsConnectingOnResume:Z

    :goto_0
    return-void
.end method
