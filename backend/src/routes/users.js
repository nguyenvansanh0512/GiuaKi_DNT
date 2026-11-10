const router = require('express').Router();
const c = require('../controllers/users');
router.use(c.databaseReady);
router.route('/').get(c.list).post(c.create);
router.route('/:id').all(c.checkId).get(c.get).put(c.update).delete(c.remove);
module.exports = router;
