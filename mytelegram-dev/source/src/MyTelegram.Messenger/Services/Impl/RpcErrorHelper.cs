namespace MyTelegram.Messenger.Services.Impl;
public class RpcErrorHelper(IObjectMessageSender objectMessageSender) : IRpcErrorHelper, ITransientDependency
{
    public Task ThrowRpcErrorAsync(RequestInfo requestInfo, RpcError rpcError)
    {
        return objectMessageSender.SendRpcMessageToClientAsync(requestInfo, rpcError.ToRpcError());
    }

    public Task ThrowRpcErrorAsync(IRequestInput requestInfo, RpcError rpcError)
    {
        return objectMessageSender.SendRpcMessageToClientAsync(requestInfo.ToRequestInfo(), rpcError.ToRpcError());
    }
}
