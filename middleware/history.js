const jwt = require('jsonwebtoken');

module.exports = {
  validateHistoryAccess: (req, res, next) => {
    if (!req.headers.authorization) {
      return res.status(400).json({
        message: 'Your session is not valid!',
      });
    }

    try {
      const authHeader = req.headers.authorization;
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, 'SECRETKEY');
      req.userData = decoded;
      next();
    } catch (err) {
      return res.status(400).json({
        message: 'Your session is not valid!',
      });
    }
  },
};
