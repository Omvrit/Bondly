const express = require('express');
const router = express.Router();
const SearchUser = require('../controllers/UserController/searchUser');
const SendRequest = require('../controllers/UserController/friendRequest');
const { protect, refreshToken } = require('../middleware/auth');
const Connection = require('../controllers/UserController/connections');
const Conversation = require('../controllers/UserController/conversation');
// router.get('/user/me',protect,SearchUser.getUserByUsername);
router.get('/users/:username', protect,SearchUser.getUsersByUsername);

router.post('/users/send-request/:username', protect, SendRequest.sendFriendRequest);
router.post('/users/accept-request/:username', protect, SendRequest.acceptFriendRequest);
router.post('/users/reject-request/:username', protect, SendRequest.rejectFriendRequest);
//fetch pending request
router.get('/fetch-pending-requests', protect, SendRequest.fetchPendingRequest);
//get connection
router.get('/connections', protect, Connection.getUserConnections);
//routes for conersation
router.get('/conversations/get-conversation/:id',Conversation.getConversationByParticipantId)
router.post('/conversations/create-conversation',Conversation.createConversation)
module.exports = router;