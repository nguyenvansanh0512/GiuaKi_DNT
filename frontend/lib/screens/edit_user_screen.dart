import '../models/user_model.dart';
import 'user_form_screen.dart';

class EditUserScreen extends UserFormScreen {
  const EditUserScreen({super.key, required UserModel user})
    : super(user: user);
}
