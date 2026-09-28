.class public Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;
.super Ljava/lang/Object;
.source "GameHelper.java"

.implements Lcom/google/android/gms/common/api/GoogleApiClient$ConnectionCallbacks;
.implements Lcom/google/android/gms/common/api/GoogleApiClient$OnConnectionFailedListener;

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;,
        Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$GameHelperListener;
    }
.end annotation

.field public static final CLIENT_GAMES:I = 0x1

.field public static final CLIENT_NONE:I = 0x0

.field static final MAX_SIGN_IN_ATTEMPTS:I = 0x1

.field static final RC_RESOLVE:I = 0x2329

.field static final RC_UNUSED:I = 0x232a

.field static final TAG:Ljava/lang/String; = "GameHelper"

.field private final GAMEHELPER_SHARED_PREFS:Ljava/lang/String;

.field private final KEY_SIGN_IN_CANCELLATIONS:Ljava/lang/String;

.field mActivity:Landroid/app/Activity;

.field mAppContext:Landroid/content/Context;

.field mConnectOnStart:Z

.field private mConnecting:Z

.field mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

.field mExpectingResolution:Z

.field mGamesApiOptions:Lcom/google/android/gms/games/Games$GamesOptions;

.field mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

.field mGoogleApiClientBuilder:Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

.field mHandler:Landroid/os/Handler;

.field public mInstalling:Z

.field mInvitation:Lcom/google/android/gms/games/multiplayer/Invitation;

.field mListener:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$GameHelperListener;

.field mRequestedClients:I

.field mRequests:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Lcom/google/android/gms/games/request/GameRequest;",
            ">;"
        }
    .end annotation
.end field

.field private mSetupDone:Z

.field mShowErrorDialogs:Z

.field mSignInCancelled:Z

.field mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

.field mTurnBasedMatch:Lcom/google/android/gms/games/multiplayer/turnbased/TurnBasedMatch;

.field mUserInitiatedSignIn:Z

.method public constructor <init>(Landroid/app/Activity;)V
    .locals 3

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, 0x0

    .line 2
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSetupDone:Z

    .line 3
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    .line 4
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mInstalling:Z

    .line 5
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mExpectingResolution:Z

    .line 6
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInCancelled:Z

    const/4 v1, 0x0

    .line 7
    iput-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mActivity:Landroid/app/Activity;

    .line 8
    iput-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mAppContext:Landroid/content/Context;

    .line 9
    iput-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClientBuilder:Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    .line 10
    invoke-static {}, Lcom/google/android/gms/games/Games$GamesOptions;->builder()Lcom/google/android/gms/games/Games$GamesOptions$Builder;

    move-result-object v2

    invoke-virtual {v2}, Lcom/google/android/gms/games/Games$GamesOptions$Builder;->build()Lcom/google/android/gms/games/Games$GamesOptions;

    move-result-object v2

    iput-object v2, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGamesApiOptions:Lcom/google/android/gms/games/Games$GamesOptions;

    .line 11
    iput-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    .line 12
    iput v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequestedClients:I

    const/4 v2, 0x1

    .line 13
    iput-boolean v2, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectOnStart:Z

    .line 14
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mUserInitiatedSignIn:Z

    .line 15
    iput-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

    .line 16
    iput-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    .line 17
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mShowErrorDialogs:Z

    .line 18
    iput-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mListener:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$GameHelperListener;

    const-string v0, "GAMEHELPER_SHARED_PREFS"

    .line 19
    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->GAMEHELPER_SHARED_PREFS:Ljava/lang/String;

    const-string v0, "KEY_SIGN_IN_CANCELLATIONS"

    .line 20
    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->KEY_SIGN_IN_CANCELLATIONS:Ljava/lang/String;

    .line 21
    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mActivity:Landroid/app/Activity;

    .line 22
    invoke-virtual {p1}, Landroid/app/Activity;->getApplicationContext()Landroid/content/Context;

    move-result-object p1

    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mAppContext:Landroid/content/Context;

    .line 23
    new-instance p1, Landroid/os/Handler;

    invoke-direct {p1}, Landroid/os/Handler;-><init>()V

    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mHandler:Landroid/os/Handler;

    return-void
.end method

.method private doApiOptionsPreCheck()V
    .locals 3

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClientBuilder:Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    if-nez v0, :cond_0

    return-void

    :cond_0
    const-string v0, "GameHelper: you cannot call set*ApiOptions after the client builder has been created. Call it before calling createApiClientBuilder() or setup()."

    .line 2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "*** GameHelper ERROR: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Major_Error(Ljava/lang/String;)V

    .line 3
    new-instance v1, Ljava/lang/IllegalStateException;

    invoke-direct {v1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method static makeSimpleDialog(Landroid/app/Activity;Ljava/lang/String;)Landroid/app/Dialog;
    .locals 1

    .line 1
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v0, p1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    const p1, 0x104000a

    const/4 v0, 0x0

    .line 2
    invoke-virtual {p0, p1, v0}, Landroid/app/AlertDialog$Builder;->setNeutralButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    invoke-virtual {p0}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object p0

    return-object p0
.end method

.method static makeSimpleDialog(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)Landroid/app/Dialog;
    .locals 1

    .line 3
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v0, p2}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    .line 4
    invoke-virtual {p0, p1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    const p1, 0x104000a

    const/4 p2, 0x0

    invoke-virtual {p0, p1, p2}, Landroid/app/AlertDialog$Builder;->setNeutralButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p0

    .line 5
    invoke-virtual {p0}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object p0

    return-object p0
.end method

.method public static showFailureDialog(Landroid/app/Activity;II)V
    .locals 1

    if-nez p0, :cond_0

    const-string p0, "*** GameHelper ERROR: *** No Activity. Can\'t show failure dialog!"

    .line 7
    invoke-static {p0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Major_Error(Ljava/lang/String;)V

    return-void

    :cond_0
    packed-switch p1, :pswitch_data_0

    const/16 p1, 0x3ee

    const/4 v0, 0x0

    .line 8
    invoke-static {p2, p0, p1, v0}, Lcom/google/android/gms/common/GooglePlayServicesUtil;->getErrorDialog(ILandroid/app/Activity;ILandroid/content/DialogInterface$OnCancelListener;)Landroid/app/Dialog;

    move-result-object p1

    if-nez p1, :cond_1

    const-string p1, "*** GameHelper ERROR: No standard error dialog available. Making fallback dialog."

    .line 9
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Major_Error(Ljava/lang/String;)V

    .line 10
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v0, 0x0

    .line 11
    invoke-static {p0, v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelperUtils;->getString(Landroid/content/Context;I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, " "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 12
    invoke-static {p2}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelperUtils;->errorCodeToString(I)Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 13
    invoke-static {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->makeSimpleDialog(Landroid/app/Activity;Ljava/lang/String;)Landroid/app/Dialog;

    move-result-object p0

    goto :goto_0

    :pswitch_0
    const/4 p1, 0x2

    .line 14
    invoke-static {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelperUtils;->getString(Landroid/content/Context;I)Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->makeSimpleDialog(Landroid/app/Activity;Ljava/lang/String;)Landroid/app/Dialog;

    move-result-object p0

    goto :goto_0

    :pswitch_1
    const/4 p1, 0x3

    .line 15
    invoke-static {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelperUtils;->getString(Landroid/content/Context;I)Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->makeSimpleDialog(Landroid/app/Activity;Ljava/lang/String;)Landroid/app/Dialog;

    move-result-object p0

    goto :goto_0

    :pswitch_2
    const/4 p1, 0x1

    .line 16
    invoke-static {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelperUtils;->getString(Landroid/content/Context;I)Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->makeSimpleDialog(Landroid/app/Activity;Ljava/lang/String;)Landroid/app/Dialog;

    move-result-object p0

    goto :goto_0

    :cond_1
    move-object p0, p1

    .line 17
    :goto_0
    invoke-virtual {p0}, Landroid/app/Dialog;->show()V

    return-void

    :pswitch_data_0
    .packed-switch 0x2712
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public HasClient(I)Z
    .locals 1

    iget v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequestedClients:I

    and-int/2addr p1, v0

    if-eqz p1, :cond_0

    const/4 p1, 0x1

    goto :goto_0

    :cond_0
    const/4 p1, 0x0

    :goto_0
    return p1
.end method

.method public IsSignInCancelled()Z
    .locals 1

    iget-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInCancelled:Z

    return v0
.end method

.method public addClient(I)V
    .locals 1

    iget v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequestedClients:I

    or-int/2addr p1, v0

    iput p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequestedClients:I

    return-void
.end method

.method assertConfigured(Ljava/lang/String;)V
    .locals 2

    .line 1
    iget-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSetupDone:Z

    if-eqz v0, :cond_0

    return-void

    .line 2
    :cond_0
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper error: Operation attempted without setup: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p1, ". The setup() method must be called before attempting any other operation."

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 3
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "*** GameHelper ERROR: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Major_Error(Ljava/lang/String;)V

    .line 4
    new-instance v0, Ljava/lang/IllegalStateException;

    invoke-direct {v0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public beginUserInitiatedSignIn()V
    .locals 0

    return-void
.end method

.method public clearInvitation()V
    .locals 1

    const/4 v0, 0x0

    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mInvitation:Lcom/google/android/gms/games/multiplayer/Invitation;

    return-void
.end method

.method public clearRequests()V
    .locals 1

    const/4 v0, 0x0

    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequests:Ljava/util/ArrayList;

    return-void
.end method

.method public clearTurnBasedMatch()V
    .locals 1

    const/4 v0, 0x0

    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mTurnBasedMatch:Lcom/google/android/gms/games/multiplayer/turnbased/TurnBasedMatch;

    return-void
.end method

.method connect()V
    .locals 0

    return-void
.end method

.method public createApiClientBuilder()Lcom/google/android/gms/common/api/GoogleApiClient$Builder;
    .locals 3

    .line 1
    iget-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSetupDone:Z

    if-nez v0, :cond_1

    .line 2
    new-instance v0, Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mActivity:Landroid/app/Activity;

    invoke-direct {v0, v1, p0, p0}, Lcom/google/android/gms/common/api/GoogleApiClient$Builder;-><init>(Landroid/content/Context;Lcom/google/android/gms/common/api/GoogleApiClient$ConnectionCallbacks;Lcom/google/android/gms/common/api/GoogleApiClient$OnConnectionFailedListener;)V

    const/4 v1, 0x1

    .line 3
    invoke-virtual {p0, v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->HasClient(I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 4
    sget-object v1, Lcom/google/android/gms/games/Games;->API:Lcom/google/android/gms/common/api/Api;

    iget-object v2, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGamesApiOptions:Lcom/google/android/gms/games/Games$GamesOptions;

    invoke-virtual {v0, v1, v2}, Lcom/google/android/gms/common/api/GoogleApiClient$Builder;->addApi(Lcom/google/android/gms/common/api/Api;Lcom/google/android/gms/common/api/Api$ApiOptions$HasOptions;)Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    .line 5
    sget-object v1, Lcom/google/android/gms/games/Games;->SCOPE_GAMES:Lcom/google/android/gms/common/api/Scope;

    invoke-virtual {v0, v1}, Lcom/google/android/gms/common/api/GoogleApiClient$Builder;->addScope(Lcom/google/android/gms/common/api/Scope;)Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    .line 6
    :cond_0
    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClientBuilder:Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    return-object v0

    :cond_1
    const-string v0, "GameHelper: you called GameHelper.createApiClientBuilder() after calling setup. You can only get a client builder BEFORE performing setup."

    .line 7
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "*** GameHelper ERROR: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Major_Error(Ljava/lang/String;)V

    .line 8
    new-instance v1, Ljava/lang/IllegalStateException;

    invoke-direct {v1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public disconnect()V
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->isConnected()Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "GameHelper: Disconnecting client."

    .line 2
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 3
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->disconnect()V

    goto :goto_0

    :cond_0
    const-string v0, "!!! GameHelper WARNING: disconnect() called when client was already disconnected."

    .line 4
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Minor_Error(Ljava/lang/String;)V

    :goto_0
    return-void
.end method

.method public getApiClient()Lcom/google/android/gms/common/api/GoogleApiClient;
    .locals 2

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    if-eqz v0, :cond_0

    return-object v0

    .line 2
    :cond_0
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "No GoogleApiClient. Did you call setup()?"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public getInvitation()Lcom/google/android/gms/games/multiplayer/Invitation;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->isConnected()Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "!!! GameHelper WARNING: Warning: getInvitation() should only be called when signed in, that is, after getting onSignInSuceeded()"

    .line 2
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Minor_Error(Ljava/lang/String;)V

    .line 3
    :cond_0
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mInvitation:Lcom/google/android/gms/games/multiplayer/Invitation;

    return-object v0
.end method

.method public getInvitationId()Ljava/lang/String;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->isConnected()Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "!!! GameHelper WARNING: Warning: getInvitationId() should only be called when signed in, that is, after getting onSignInSuceeded()"

    .line 2
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Minor_Error(Ljava/lang/String;)V

    .line 3
    :cond_0
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mInvitation:Lcom/google/android/gms/games/multiplayer/Invitation;

    if-nez v0, :cond_1

    const/4 v0, 0x0

    goto :goto_0

    :cond_1
    invoke-interface {v0}, Lcom/google/android/gms/games/multiplayer/Invitation;->getInvitationId()Ljava/lang/String;

    move-result-object v0

    :goto_0
    return-object v0
.end method

.method public getRequests()Ljava/util/ArrayList;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/ArrayList<",
            "Lcom/google/android/gms/games/request/GameRequest;",
            ">;"
        }
    .end annotation

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->isConnected()Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "!!! GameHelper WARNING: Warning: getRequests() should only be called when signed in, that is, after getting onSignInSuceeded()"

    .line 2
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Minor_Error(Ljava/lang/String;)V

    .line 3
    :cond_0
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequests:Ljava/util/ArrayList;

    return-object v0
.end method

.method getSignInAttempts()I
    .locals 3

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mAppContext:Landroid/content/Context;

    const-string v1, "GAMEHELPER_SHARED_PREFS"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v0

    const-string v1, "KEY_SIGN_IN_CANCELLATIONS"

    .line 2
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getInt(Ljava/lang/String;I)I

    move-result v0

    return v0
.end method

.method public getSignInError()Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;
    .locals 1

    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    return-object v0
.end method

.method public getTurnBasedMatch()Lcom/google/android/gms/games/multiplayer/turnbased/TurnBasedMatch;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->isConnected()Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "!!! GameHelper WARNING: Warning: getTurnBasedMatch() should only be called when signed in, that is, after getting onSignInSuceeded()"

    .line 2
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Minor_Error(Ljava/lang/String;)V

    .line 3
    :cond_0
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mTurnBasedMatch:Lcom/google/android/gms/games/multiplayer/turnbased/TurnBasedMatch;

    return-object v0
.end method

.method giveUp(Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;)V
    .locals 3

    const/4 v0, 0x0

    .line 1
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectOnStart:Z

    .line 2
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->disconnect()V

    .line 3
    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    .line 4
    iget v1, p1, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;->mActivityResultCode:I

    const/16 v2, 0x2714

    if-ne v1, v2, :cond_0

    .line 5
    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mAppContext:Landroid/content/Context;

    invoke-static {v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelperUtils;->printMisconfiguredDebugInfo(Landroid/content/Context;)V

    .line 6
    :cond_0
    invoke-virtual {p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;->getServiceErrorCode()I

    move-result p1

    const/16 v1, 0x1e

    if-eq p1, v1, :cond_1

    .line 7
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->showFailureDialog()V

    .line 8
    :cond_1
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    .line 9
    invoke-virtual {p0, v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->notifyListener(Z)V

    return-void
.end method

.method public hasInvitation()Z
    .locals 1

    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mInvitation:Lcom/google/android/gms/games/multiplayer/Invitation;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public hasRequests()Z
    .locals 1

    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequests:Ljava/util/ArrayList;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public hasSignInError()Z
    .locals 1

    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public hasTurnBasedMatch()Z
    .locals 1

    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mTurnBasedMatch:Lcom/google/android/gms/games/multiplayer/turnbased/TurnBasedMatch;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public isConnecting()Z
    .locals 1

    iget-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    return v0
.end method

.method public isGooglePlayServicesAvailable()I
    .locals 3

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mAppContext:Landroid/content/Context;

    invoke-static {v0}, Lcom/google/android/gms/common/GooglePlayServicesUtil;->isGooglePlayServicesAvailable(Landroid/content/Context;)I

    move-result v0

    .line 2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Google: isGooglePlayServicesAvailable returned "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    return v0
.end method

.method public isSignedIn()Z
    .locals 1

    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->isConnected()Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public makeSimpleDialog(Ljava/lang/String;)Landroid/app/Dialog;
    .locals 1

    .line 6
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mActivity:Landroid/app/Activity;

    if-nez v0, :cond_0

    const-string p1, "*** GameHelper ERROR: *** makeSimpleDialog failed: no current Activity!"

    .line 7
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Major_Error(Ljava/lang/String;)V

    const/4 p1, 0x0

    return-object p1

    .line 8
    :cond_0
    invoke-static {v0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->makeSimpleDialog(Landroid/app/Activity;Ljava/lang/String;)Landroid/app/Dialog;

    move-result-object p1

    return-object p1
.end method

.method public makeSimpleDialog(Ljava/lang/String;Ljava/lang/String;)Landroid/app/Dialog;
    .locals 1

    .line 9
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mActivity:Landroid/app/Activity;

    if-nez v0, :cond_0

    const-string p1, "*** GameHelper ERROR: *** makeSimpleDialog failed: no current Activity!"

    .line 10
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Major_Error(Ljava/lang/String;)V

    const/4 p1, 0x0

    return-object p1

    .line 11
    :cond_0
    invoke-static {v0, p1, p2}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->makeSimpleDialog(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)Landroid/app/Dialog;

    move-result-object p1

    return-object p1
.end method

.method markSignInAttempts()I
    .locals 3

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mAppContext:Landroid/content/Context;

    const-string v1, "GAMEHELPER_SHARED_PREFS"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v0

    .line 2
    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    const-string v1, "KEY_SIGN_IN_CANCELLATIONS"

    const/4 v2, 0x1

    .line 3
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences$Editor;->putInt(Ljava/lang/String;I)Landroid/content/SharedPreferences$Editor;

    .line 4
    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->commit()Z

    return v2
.end method

.method notifyListener(Z)V
    .locals 2

    .line 1
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper: Notifying LISTENER of sign-in "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    if-eqz p1, :cond_0

    const-string v1, "SUCCESS"

    goto :goto_0

    .line 2
    :cond_0
    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    if-eqz v1, :cond_1

    const-string v1, "FAILURE (error)"

    goto :goto_0

    :cond_1
    const-string v1, "FAILURE (no error)"

    .line 3
    :goto_0
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 4
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 5
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mListener:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$GameHelperListener;

    if-eqz v0, :cond_3

    if-eqz p1, :cond_2

    .line 6
    invoke-interface {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$GameHelperListener;->onSignInSucceeded()V

    goto :goto_1

    .line 7
    :cond_2
    invoke-interface {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$GameHelperListener;->onSignInFailed()V

    :cond_3
    :goto_1
    return-void
.end method

.method public onActivityResult(IILandroid/content/Intent;)V
    .locals 3

    .line 1
    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct {p3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "GameHelper: onActivityResult: req="

    invoke-virtual {p3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const/16 v0, 0x2329

    if-ne p1, v0, :cond_0

    const-string v1, "RC_RESOLVE"

    goto :goto_0

    .line 2
    :cond_0
    invoke-static {p1}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v1

    :goto_0
    invoke-virtual {p3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", resp="

    invoke-virtual {p3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 3
    invoke-static {p2}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelperUtils;->activityResponseCodeToString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p3

    .line 4
    invoke-static {p3}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    if-eq p1, v0, :cond_1

    const-string p1, "GameHelper: onActivityResult: request code not meant for us. Ignoring."

    .line 5
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    return-void

    :cond_1
    const/4 p1, 0x0

    .line 6
    iput-boolean p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mExpectingResolution:Z

    .line 7
    iget-boolean p3, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    if-nez p3, :cond_2

    const-string p1, "GameHelper: onActivityResult: ignoring because we are not connecting."

    .line 8
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    return-void

    :cond_2
    const/4 p3, -0x1

    if-ne p2, p3, :cond_3

    const-string p1, "GameHelper: onAR: Resolution was RESULT_OK, so connecting current client again."

    .line 9
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 10
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->connect()V

    goto/16 :goto_1

    :cond_3
    const/16 p3, 0x2711

    if-ne p2, p3, :cond_4

    const-string p1, "GameHelper: onAR: Resolution was RECONNECT_REQUIRED, so reconnecting."

    .line 11
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 12
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->connect()V

    goto :goto_1

    :cond_4
    if-nez p2, :cond_5

    const-string p2, "GameHelper: onAR: Got a cancellation result, so disconnecting."

    .line 13
    invoke-static {p2}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const/4 p2, 0x1

    .line 14
    iput-boolean p2, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInCancelled:Z

    .line 15
    iput-boolean p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectOnStart:Z

    .line 16
    iput-boolean p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mUserInitiatedSignIn:Z

    const/4 p3, 0x0

    .line 17
    iput-object p3, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    .line 18
    iput-boolean p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    .line 19
    iput-object p3, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

    .line 20
    iget-object p3, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {p3}, Lcom/google/android/gms/common/api/GoogleApiClient;->disconnect()V

    .line 21
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->getSignInAttempts()I

    move-result p3

    .line 22
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->markSignInAttempts()I

    move-result v0

    .line 23
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "GameHelper: onAR: # of cancellations "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p3, " --> "

    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p3, ", max "

    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-static {p2}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 24
    invoke-virtual {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->notifyListener(Z)V

    goto :goto_1

    .line 25
    :cond_5
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string p3, "GameHelper: onAR: responseCode="

    invoke-virtual {p1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 26
    invoke-static {p2}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelperUtils;->activityResponseCodeToString(I)Ljava/lang/String;

    move-result-object p3

    invoke-virtual {p1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p3, ", so giving up."

    invoke-virtual {p1, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 27
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 28
    new-instance p1, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    iget-object p3, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

    invoke-virtual {p3}, Lcom/google/android/gms/common/ConnectionResult;->getErrorCode()I

    move-result p3

    invoke-direct {p1, p3, p2}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;-><init>(II)V

    invoke-virtual {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->giveUp(Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;)V

    :goto_1
    return-void
.end method

.method public onConnected(Landroid/os/Bundle;)V
    .locals 2

    const-string v0, "GameHelper: onConnected: connected!"

    .line 1
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    if-eqz p1, :cond_2

    const-string v0, "GameHelper: onConnected: connection hint provided. Checking for invite."

    .line 2
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const-string v0, "invitation"

    .line 3
    invoke-virtual {p1, v0}, Landroid/os/Bundle;->getParcelable(Ljava/lang/String;)Landroid/os/Parcelable;

    move-result-object v0

    check-cast v0, Lcom/google/android/gms/games/multiplayer/Invitation;

    if-eqz v0, :cond_0

    .line 4
    invoke-interface {v0}, Lcom/google/android/gms/games/multiplayer/Invitation;->getInvitationId()Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_0

    const-string v1, "GameHelper: onConnected: connection hint has a room invite!"

    .line 5
    invoke-static {v1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 6
    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mInvitation:Lcom/google/android/gms/games/multiplayer/Invitation;

    .line 7
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper: Invitation ID: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mInvitation:Lcom/google/android/gms/games/multiplayer/Invitation;

    invoke-interface {v1}, Lcom/google/android/gms/games/multiplayer/Invitation;->getInvitationId()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 8
    :cond_0
    sget-object v0, Lcom/google/android/gms/games/Games;->Requests:Lcom/google/android/gms/games/request/Requests;

    invoke-interface {v0, p1}, Lcom/google/android/gms/games/request/Requests;->getGameRequestsFromBundle(Landroid/os/Bundle;)Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequests:Ljava/util/ArrayList;

    .line 9
    invoke-virtual {v0}, Ljava/util/ArrayList;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_1

    .line 10
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper: onConnected: connection hint has "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequests:Ljava/util/ArrayList;

    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, " request(s)"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    :cond_1
    const-string v0, "GameHelper: onConnected: connection hint provided. Checking for TBMP game."

    .line 11
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const-string v0, "turn_based_match"

    .line 12
    invoke-virtual {p1, v0}, Landroid/os/Bundle;->getParcelable(Ljava/lang/String;)Landroid/os/Parcelable;

    move-result-object p1

    check-cast p1, Lcom/google/android/gms/games/multiplayer/turnbased/TurnBasedMatch;

    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mTurnBasedMatch:Lcom/google/android/gms/games/multiplayer/turnbased/TurnBasedMatch;

    :cond_2
    const/4 p1, 0x1

    .line 13
    invoke-virtual {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->HasClient(I)Z

    move-result p1

    if-eqz p1, :cond_3

    .line 14
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->succeedSignIn()V

    goto :goto_0

    .line 15
    :cond_3
    new-instance p1, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    const/16 v0, 0x1e

    invoke-direct {p1, v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;-><init>(I)V

    invoke-virtual {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->giveUp(Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;)V

    :goto_0
    return-void
.end method

.method public onConnectionFailed(Lcom/google/android/gms/common/ConnectionResult;)V
    .locals 5

    const-string v0, "GameHelper: onConnectionFailed"

    .line 1
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 2
    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

    const-string v0, "GameHelper: Connection failure:"

    .line 3
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 4
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper:    - code: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

    invoke-virtual {v1}, Lcom/google/android/gms/common/ConnectionResult;->getErrorCode()I

    move-result v1

    invoke-static {v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelperUtils;->errorCodeToString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 5
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper:    - resolvable: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

    invoke-virtual {v1}, Lcom/google/android/gms/common/ConnectionResult;->hasResolution()Z

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 6
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper:    - details: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

    invoke-virtual {v1}, Lcom/google/android/gms/common/ConnectionResult;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 7
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->getSignInAttempts()I

    move-result v0

    .line 8
    iget-boolean v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mUserInitiatedSignIn:Z

    const/4 v2, 0x0

    const/4 v3, 0x1

    if-eqz v1, :cond_0

    const-string v0, "GameHelper: onConnectionFailed: WILL resolve because user initiated sign-in."

    .line 9
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    goto :goto_1

    .line 10
    :cond_0
    iget-boolean v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInCancelled:Z

    if-eqz v1, :cond_1

    const-string v0, "GameHelper: onConnectionFailed WILL NOT resolve (user already cancelled once)."

    .line 11
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    :goto_0
    const/4 v3, 0x0

    goto :goto_1

    :cond_1
    if-ge v0, v3, :cond_2

    .line 12
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "GameHelper: onConnectionFailed: WILL resolve because we have below the max# of attempts, "

    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, " < "

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    goto :goto_1

    .line 13
    :cond_2
    new-instance v1, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    iget-object v4, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

    invoke-virtual {v4}, Lcom/google/android/gms/common/ConnectionResult;->getErrorCode()I

    move-result v4

    invoke-direct {v1, v4}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;-><init>(I)V

    iput-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    .line 14
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "GameHelper: onConnectionFailed: Will NOT resolve; not user-initiated and max attempts reached: "

    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, " >= "

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    goto :goto_0

    :goto_1
    if-nez v3, :cond_3

    const-string v0, "GameHelper: onConnectionFailed: since we won\'t resolve, failing now."

    .line 15
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 16
    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectionResult:Lcom/google/android/gms/common/ConnectionResult;

    .line 17
    iput-boolean v2, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    .line 18
    invoke-virtual {p0, v2}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->notifyListener(Z)V

    return-void

    :cond_3
    const-string p1, "GameHelper: onConnectionFailed: resolving problem..."

    .line 19
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 20
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->resolveConnectionResult()V

    return-void
.end method

.method public onConnectionSuspended(I)V
    .locals 2

    .line 1
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper: onConnectionSuspended, cause="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 2
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->disconnect()V

    const/4 p1, 0x0

    .line 3
    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    const-string p1, "GameHelper: Making extraordinary call to onSignInFailed callback"

    .line 4
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const/4 p1, 0x0

    .line 5
    iput-boolean p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    .line 6
    invoke-virtual {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->notifyListener(Z)V

    return-void
.end method

.method public onStart(Landroid/app/Activity;Z)V
    .locals 2

    .line 1
    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mActivity:Landroid/app/Activity;

    .line 2
    invoke-virtual {p1}, Landroid/app/Activity;->getApplicationContext()Landroid/content/Context;

    move-result-object p1

    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mAppContext:Landroid/content/Context;

    const-string p1, "GameHelper: onStart"

    .line 3
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const-string p1, "onStart"

    .line 4
    invoke-virtual {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->assertConfigured(Ljava/lang/String;)V

    .line 5
    const/4 p1, 0x0

    if-eqz p1, :cond_1

    if-nez p2, :cond_1

    .line 6
    iget-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {p1}, Lcom/google/android/gms/common/api/GoogleApiClient;->isConnected()Z

    move-result p1

    if-eqz p1, :cond_0

    const-string p1, "!!! GameHelper WARNING: GameHelper: client was already connected on onStart()"

    .line 7
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Minor_Error(Ljava/lang/String;)V

    goto :goto_0

    :cond_0
    const-string p1, "GameHelper: Connecting client."

    .line 8
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const/4 p1, 0x1

    .line 9
    iput-boolean p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    .line 10
    iget-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {p1}, Lcom/google/android/gms/common/api/GoogleApiClient;->connect()V

    goto :goto_0

    :cond_1
    if-eqz p2, :cond_2

    const-string p1, "GameHelper: Not attempting to connect becase deferAutoLogIn=true"

    .line 11
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    goto :goto_0

    :cond_2
    const-string p1, "GameHelper: Not attempting to connect becase mConnectOnStart=false"

    .line 12
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const-string p1, "GameHelper: Instead, reporting a sign-in failure."

    .line 13
    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 14
    iget-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mHandler:Landroid/os/Handler;

    new-instance p2, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$1;

    invoke-direct {p2, p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$1;-><init>(Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;)V

    const-wide/16 v0, 0x3e8

    invoke-virtual {p1, p2, v0, v1}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :goto_0
    return-void
.end method

.method public onStop()V
    .locals 1

    const-string v0, "GameHelper: onStop"

    .line 1
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const-string v0, "onStop"

    .line 2
    invoke-virtual {p0, v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->assertConfigured(Ljava/lang/String;)V

    .line 3
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->isConnected()Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "GameHelper: Disconnecting client due to onStop"

    .line 4
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 5
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->disconnect()V

    goto :goto_0

    :cond_0
    const-string v0, "GameHelper: Client already disconnected when we got onStop."

    .line 6
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    :goto_0
    const/4 v0, 0x0

    .line 7
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    .line 8
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mExpectingResolution:Z

    const/4 v0, 0x0

    .line 9
    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mActivity:Landroid/app/Activity;

    return-void
.end method

.method public reconnectClient()V
    .locals 0

    return-void
.end method

.method public removeClient(I)V
    .locals 1

    .line 1
    invoke-virtual {p0, p1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->HasClient(I)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 2
    iget v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequestedClients:I

    not-int p1, p1

    and-int/2addr p1, v0

    iput p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequestedClients:I

    :cond_0
    return-void
.end method

.method resetSignInAttempts()V
    .locals 3

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mAppContext:Landroid/content/Context;

    const-string v1, "GAMEHELPER_SHARED_PREFS"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v0

    .line 2
    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    const-string v1, "KEY_SIGN_IN_CANCELLATIONS"

    .line 3
    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences$Editor;->putInt(Ljava/lang/String;I)Landroid/content/SharedPreferences$Editor;

    .line 4
    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->commit()Z

    return-void
.end method

.method resolveConnectionResult()V
    .locals 0

    return-void
.end method

.method public setConnectOnStart(Z)V
    .locals 2

    .line 1
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper: Forcing mConnectOnStart="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 2
    iput-boolean p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectOnStart:Z

    return-void
.end method

.method public setGamesApiOptions(Lcom/google/android/gms/games/Games$GamesOptions;)V
    .locals 0

    .line 1
    invoke-direct {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->doApiOptionsPreCheck()V

    .line 2
    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGamesApiOptions:Lcom/google/android/gms/games/Games$GamesOptions;

    return-void
.end method

.method public setShowErrorDialogs(Z)V
    .locals 0

    iput-boolean p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mShowErrorDialogs:Z

    return-void
.end method

.method public setup(Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$GameHelperListener;I)V
    .locals 1

    .line 1
    iget-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSetupDone:Z

    if-nez v0, :cond_1

    .line 2
    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mListener:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$GameHelperListener;

    .line 3
    iput p2, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequestedClients:I

    .line 4
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string p2, "GameHelper: Setup: requested clients: "

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget p2, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mRequestedClients:I

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 5
    iget-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClientBuilder:Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    if-nez p1, :cond_0

    .line 6
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->createApiClientBuilder()Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    .line 7
    :cond_0
    iget-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClientBuilder:Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    invoke-virtual {p1}, Lcom/google/android/gms/common/api/GoogleApiClient$Builder;->build()Lcom/google/android/gms/common/api/GoogleApiClient;

    move-result-object p1

    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    const/4 p1, 0x0

    .line 8
    iput-object p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClientBuilder:Lcom/google/android/gms/common/api/GoogleApiClient$Builder;

    const/4 p1, 0x1

    .line 9
    iput-boolean p1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSetupDone:Z

    return-void

    :cond_1
    const-string p1, "GameHelper: you cannot call GameHelper.setup() more than once!"

    .line 10
    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "*** GameHelper ERROR: "

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-static {p2}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Major_Error(Ljava/lang/String;)V

    .line 11
    new-instance p2, Ljava/lang/IllegalStateException;

    invoke-direct {p2, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p2
.end method

.method public showFailureDialog()V
    .locals 3

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    if-eqz v0, :cond_1

    .line 2
    invoke-virtual {v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;->getServiceErrorCode()I

    move-result v0

    .line 3
    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    invoke-virtual {v1}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;->getActivityResultCode()I

    move-result v1

    .line 4
    iget-boolean v2, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mShowErrorDialogs:Z

    if-eqz v2, :cond_0

    .line 5
    iget-object v2, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mActivity:Landroid/app/Activity;

    invoke-static {v2, v1, v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->showFailureDialog(Landroid/app/Activity;II)V

    goto :goto_0

    .line 6
    :cond_0
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "GameHelper: Not showing error dialog because mShowErrorDialogs==false. Error was: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    :cond_1
    :goto_0
    return-void
.end method

.method public signOut()V
    .locals 3

    .line 1
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->isConnected()Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "GameHelper: signOut: was already disconnected, ignoring."

    .line 2
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    return-void

    :cond_0
    const/4 v0, 0x1

    .line 3
    invoke-virtual {p0, v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->HasClient(I)Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "GameHelper: Signing out from the Google API Client."

    .line 4
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    .line 5
    :try_start_0
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-static {v0}, Lcom/google/android/gms/games/Games;->signOut(Lcom/google/android/gms/common/api/GoogleApiClient;)Lcom/google/android/gms/common/api/PendingResult;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 6
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Sign out on Games Exception: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    :cond_1
    :goto_0
    const-string v0, "GameHelper: Disconnecting client."

    .line 7
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const/4 v0, 0x0

    .line 8
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectOnStart:Z

    .line 9
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    .line 10
    iget-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mGoogleApiClient:Lcom/google/android/gms/common/api/GoogleApiClient;

    invoke-virtual {v0}, Lcom/google/android/gms/common/api/GoogleApiClient;->disconnect()V

    return-void
.end method

.method succeedSignIn()V
    .locals 2

    const-string v0, "GameHelper: succeedSignIn"

    .line 1
    invoke-static {v0}, Lcom/gameloft/GLSocialLib/ConsoleAndroidGLSocialLib;->Log_Debug(Ljava/lang/String;)V

    const/4 v0, 0x0

    .line 2
    iput-object v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mSignInFailureReason:Lcom/gameloft/GLSocialLib/GameAPI/GameHelper$SignInFailureReason;

    const/4 v0, 0x1

    .line 3
    iput-boolean v0, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnectOnStart:Z

    const/4 v1, 0x0

    .line 4
    iput-boolean v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mUserInitiatedSignIn:Z

    .line 5
    iput-boolean v1, p0, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->mConnecting:Z

    .line 6
    invoke-virtual {p0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->markSignInAttempts()I

    .line 7
    invoke-virtual {p0, v0}, Lcom/gameloft/GLSocialLib/GameAPI/GameHelper;->notifyListener(Z)V

    return-void
.end method
