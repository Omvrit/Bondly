const User = require('../../models/User');

// GET /api/users/:username
exports.getUserByUsername = async (req, res) => {
  const { username } = req.params;

  try {
    const user = await User.findOne({ username }).select('-password -refreshToken');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json(user);
  } catch (err) {
    console.error("Error fetching user:", err);
    res.status(500).json({ message: 'Server error' });
  }
};
