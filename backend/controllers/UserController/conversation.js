const Conversation = require('../../models/Conversation');
const Message = require('../../models/Message');
const User = require('../../models/User');

exports.createConversation = async (req, res) => {
    try {
        console.log("Creating conversation", req.body);
        const { participants } = req.body;
        const conversation = await Conversation.create({ participants });
        res.status(201).json(conversation);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getConversation = async (req, res) => {
    try {
        const { id } = req.params;
        const conversation = await Conversation.findById(id).populate('participants');
        res.status(200).json(conversation);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getConversationByParticipantId = async (req, res) => {
    try {
        const { id } = req.params;
        
        const conversations = await Conversation.find({
            participants: id
        })
        .populate({
            path: 'participants',
            select: 'username avatar email online'
        })
        .populate({
            path: 'lastMessage',
            select: 'content createdAt'
        })
        .sort({ lastUpdated: -1 });

        const formattedConversations = conversations.map(convo => {
            // For 1-on-1 chats, find the other participant
            const otherParticipant = convo.participants.find(
                p => p._id.toString() !== id
            );
            
            // For group chats
            const groupMembers = convo.participants
                .filter(p => p._id.toString() !== id)
                .map(p => p.username)
                .join(', ');

            return {
                _id: convo._id,
                participants: convo.participants,
                lastMessage: convo.lastMessage?.content || 'No messages yet',
                lastUpdated: convo.lastUpdated || convo.createdAt,
                otherUserId: otherParticipant?._id || null,
                otherUserName: convo.isGroup 
                    ? convo.groupName || `Group with ${groupMembers}`
                    : otherParticipant?.username || 'Unknown',
                otherUserProfilePic: convo.isGroup
                    ? convo.groupProfilePic
                    : otherParticipant?.avatar,
                otherUserOnline: otherParticipant?.online || false,
                
                unreadCount: convo.unreadCounts?.[id] || 0,
                isGroup: convo.isGroup,
                groupName: convo.groupName,
                groupProfilePic: convo.groupProfilePic
            };
        });

        res.status(200).json(formattedConversations);
    } catch (error) {
        console.error("Error fetching conversations:", error);
        res.status(500).json({ error: "Failed to load conversations" });
    }
}