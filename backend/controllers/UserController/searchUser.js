const User = require('../../models/User');


const levenshtein = require('fast-levenshtein'); // npm install fast-levenshtein


exports.getUsersByUsername = async (req, res) => {
  const { username } = req.params;
  console.log("Fetching similar users to:", username);

  try {
    const allUsers = await User.find({
      _id: { $ne: req.user.id } // Exclude the requester
    }).select('username email avatar online');

    if (allUsers.length === 0) {
      return res.status(404).json({ message: 'No other users found' });
    }

    // Calculate edit distance for each user
    const usersWithDistance = allUsers.map(user => {
      const distance = levenshtein.get(user.username.toLowerCase(), username.toLowerCase());
      return { user, distance };
    });

    // Sort users by ascending edit distance
    usersWithDistance.sort((a, b) => a.distance - b.distance);

    // Return only user objects, sorted
    const sortedUsers = usersWithDistance.map(item => item.user);

    res.status(200).json(sortedUsers);
  } catch (err) {
    console.error("Error in edit distance search:", err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getUserByEmail = async (req, res) => {
  console.log("Fetching user by email:", req.params.email);
  const { email } = req.params;
  try {
    const user = await User.findOne({ email }).select('username email avatar online');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json(user);
  } catch (err) {
    console.error("Error fetching user:", err);
    res.status(500).json({ message: 'Server error' });
  }

};
exports.getUserByUsername  = async (req, res) => {
  console.log("Fetching user by username:", req.params.username);
  const { username } = req.params;
  try {
    const user = await User.findOne({ username }).select('username email avatar online id');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json(user);
  } catch (err) {
    console.error("Error fetching user:", err);
    res.status(500).json({ message: 'Server error' });
  }

};
