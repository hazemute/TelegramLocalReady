using MyTelegram.Schema.Extensions;

namespace MyTelegram.Messenger.QueryServer.EventHandlers;

public class DuplicateOperationExceptionHandler(
    IQueryProcessor queryProcessor,
    IObjectMessageSender messageSender,
    ILogger<DuplicateOperationExceptionHandler> logger)
    : IEventHandler<DuplicateCommandEvent>, ITransientDependency
{
    public async Task HandleEventAsync(DuplicateCommandEvent eventData)
    {
        logger.LogWarning("Duplicate command, userId: {UserId} reqMsgId: {ReqMsgId}", eventData.UserId, eventData.ReqMsgId);
        var rpcResultReadModel = await queryProcessor.ProcessAsync(new GetRpcResultQuery(eventData.UserId, eventData.ReqMsgId));
        if (rpcResultReadModel != null)
        {
            var rpcResult = rpcResultReadModel.RpcData.ToTObject<IObject>();
            await messageSender.PushMessageToPeerAsync(eventData.UserId.ToUserPeer(), rpcResult,
                onlySendToThisAuthKeyId: eventData.PermAuthKeyId);
        }
        else
        {
            logger.LogWarning("Cannot find rpc result, userId: {UserId}, reqMsgId: {ReqMsgId}", eventData.UserId, eventData.ReqMsgId);
        }
    }
}