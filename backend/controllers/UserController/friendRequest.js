const User = require('../../models/User');
const UserConnection = require('../../models/UserConnection');
const FriendRequest = require('../../models/FriendRequest')



exports.sendFriendRequest = async (req, res) => {
  try {
    const { username } = req.params; // receiver's username
    const senderId = req.user._id;   // logged-in user (sender)

    // ✅ Step 1: Validate receiver exists
    const receiver = await User.findOne({ username });
    if (!receiver) {
      return res.status(404).json({ success: false, message: 'Receiver not found' });
    }

    // ❌ Don't allow sending request to self
    if (receiver._id.equals(senderId)) {
      return res.status(400).json({ success: false, message: 'Cannot send request to yourself' });
    }

    // ✅ Step 2: Check if a FriendRequest already exists (in either direction)
    const existingRequest = await FriendRequest.findOne({
      $or: [
        { sender: senderId, receiver: receiver._id },
        { sender: receiver._id, receiver: senderId }
      ]
    });

    if (existingRequest) {
      return res.status(409).json({ success: false, message: 'Friend request already exists' });
    }

    // ✅ Step 3: Check if a UserConnection already exists
    const existingConnection = await UserConnection.findOne({
      $or: [
        { user1: senderId, user2: receiver._id },
        { user1: receiver._id, user2: senderId }
      ]
    });

    if (existingConnection) {
      return res.status(409).json({ success: false, message: 'Connection already exists' });
    }

    
    const friendRequest = new FriendRequest({
      sender: senderId,
      receiver: receiver._id,
      status: 'pending'
    });

   
    const [user1, user2] =
      senderId.toString() < receiver._id.toString()
        ? [senderId, receiver._id]
        : [receiver._id, senderId];

    const userConnection = new UserConnection({
      user1,
      user2,
      status: 'pending'
    });

    // ✅ Step 6: Save both
    await friendRequest.save();
    await userConnection.save();

    return res.status(200).json({ success: true, message: 'Friend request sent successfully' });

  } catch (err) {
    console.error('Error sending friend request:', err);
    return res.status(500).json({ success: false, error: 'Internal server error' });
  }
};

exports.acceptFriendRequest = async (req, res) => {
  try {
    console.log("Accepting friend request", req.params);

    const { username } = req.params; // sender's username
    const receiverId = req.user._id; // the one accepting

    const sender = await User.findOne({ username });
    
    if (!sender) {
      return res.status(404).json({ success: false, error: 'Sender not found' });
    }

    // Find the friend request
    const request = await FriendRequest.findOne({
      sender: sender._id,
      receiver: receiverId,
      status: 'pending'
    });
    console.log(request);

    if (!request) {
      return res.status(404).json({ success: false, error: 'Friend request not found' });
    }

    // Determine user1 and user2 to match the unique index
    const [user1, user2] = sender._id < receiverId ? [sender._id, receiverId] : [receiverId, sender._id];

    // Find and update the user connection
    const userConnection = await UserConnection.findOne({ user1, user2 });
    if (!userConnection) {
      return res.status(404).json({ success: false, error: 'User connection not found' });
    }
    console.log(userConnection);
    userConnection.status = 'accepted';
    await userConnection.save();

    request.status = 'accepted';
    await request.save();

    res.status(200).json({ success: true, message: 'Friend request accepted successfully' });
  } catch (err) {
    console.error("Error accepting friend request:", err);
    res.status(500).json({ success: false, error: 'Server error' });
  }
};


exports.rejectFriendRequest = async (req, res) => {
  try {
    const { username } = req.params; // sender's username
    const receiverId = req.user._id; // current logged-in user

    // Find sender by username
    const sender = await User.findOne({ username });
    if (!sender) {
      return res.status(404).json({ success: false, error: 'Sender not found' });
    }

    // Find the pending friend request
    const request = await FriendRequest.findOne({
      sender: sender._id,
      receiver: receiverId,
      status: 'pending',
    });

    if (!request) {
      return res.status(404).json({ success: false, error: 'Friend request not found' });
    }

    // Update status to rejected
    request.status = 'rejected';
    await request.save();

    res.json({ success: true, message: 'Friend request rejected successfully' });
  } catch (err) {
    console.error('Error rejecting friend request:', err);
    res.status(500).json({ success: false, error: 'Server error' });
  }
};

exports.fetchPendingRequest=async(req,res)=>{
    try {
        console.log("Fetching pending friend requests");
        const userId = req.user._id;
        const pendingRequests = await FriendRequest.find({ receiver: userId, status: 'pending' }).populate('sender', '_id username avatar email online').select('_id username avatar email online');
        const pendingUserRequests = pendingRequests.map(request => {
            return {
                id: request.sender._id,
                username: request.sender.username,
                avatar: request.sender.avatar,
                email: request.sender.email,
                online: request.sender.online
            };
        })
        console.log("Pending friend requests:", pendingUserRequests);
        res.json(pendingUserRequests || []);
    } catch (err) {
        res.status(500).json({ success: false, error: 'Server error' });
    }
}
