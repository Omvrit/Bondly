const { express } = require('express');
const User = require('../../models/User');
const UserConnection = require('../../models/UserConnection');
// const UserConnection = require('../../models/UserConnection');

exports.getUserConnections = async (req, res) => {
  try {
    console.log("Getting user connections");
    const userId = req.user._id;

    const connections = await UserConnection.find({
      $or: [{ user1: userId }, { user2: userId }],
      status: 'accepted'
    })
      .populate('user1', 'username avatar email online')
      .populate('user2', 'username avatar email online');

    const connectedUsers = connections.map(conn => {
      // Determine who the "other user" is
      const isUser1 = conn.user1._id.equals(userId);
      const otherUser = isUser1 ? conn.user2 : conn.user1;

      return {
        id: otherUser._id,
        username: otherUser.username,
        avatar: otherUser.avatar,
        email: otherUser.email,
        online: otherUser.online
      };
    });

    res.status(200).json({ connectedUsers });
  } catch (err) {
    console.error('Error getting connections:', err);
    res.status(500).json({ success: false, error: 'Server error' });
  }
};

exports.getUserConnectionByUsername = async (req, res) => {
  try {
    const loggedInUserId = req.user._id;
    const { username } = req.params;

    const otherUser = await User.findOne({ username });
    if (!otherUser) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    const connection = await UserConnection.findOne({
      $or: [
        { user1: loggedInUserId, user2: otherUser._id },
        { user1: otherUser._id, user2: loggedInUserId }
      ]
    })
      .populate('user1', 'username avatar email online')
      .populate('user2', 'username avatar email online');

    if (!connection) {
      return res.status(404).json({ success: false, error: 'Connection not found' });
    }

    // Determine who the other user is in the connection
    const isUser1 = connection.user1._id.equals(loggedInUserId);
    const otherSide = isUser1 ? connection.user2 : connection.user1;

    res.json({
      success: true,
      connection: {
        status: connection.status,
        connectedAt: connection.createdAt,
        user: {
          id: otherSide._id,
          username: otherSide.username,
          avatar: otherSide.avatar,
          email: otherSide.email,
          online: otherSide.online
        }
      }
    });
  } catch (err) {
    console.error('Error getting connection by username:', err);
    res.status(500).json({ success: false, error: 'Server error' });
  }
};
