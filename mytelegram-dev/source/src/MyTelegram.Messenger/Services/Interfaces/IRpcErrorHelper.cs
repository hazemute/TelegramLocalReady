namespace MyTelegram.Messenger.Services.Interfaces;

public interface IRpcErrorHelper
{
    Task ThrowRpcErrorAsync(RequestInfo requestInfo, RpcError rpcError);
    Task ThrowRpcErrorAsync(IRequestInput requestInfo, RpcError rpcError);
}