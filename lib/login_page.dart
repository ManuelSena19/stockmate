import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'show_error_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController usernameController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  late final String email;
  bool _isObscure = true;
  final formKey = GlobalKey<FormState>();
  void validator(emailController) =>
      emailController != null && !EmailValidator.validate(emailController)
          ? 'Enter a valid email'
          : null;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.lightBlue),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: const Text(
                  'StockMate',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 20),
                  )),
              Form(
                key: formKey,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: TextField(
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    controller: usernameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        labelText: 'Company Name: ',
                        prefixIcon: Icon(Icons.person)),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextField(
                  obscureText: _isObscure,
                  enableSuggestions: false,
                  autocorrect: false,
                  controller: passwordController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                          icon: Icon(_isObscure
                              ? Icons.visibility
                              : Icons.visibility_off))),
                ),
              ),
              Container(
                height: 60,
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      String name = usernameController.text;
                      String password = passwordController.text;
                      DocumentReference userDocRef = FirebaseFirestore.instance
                          .collection('companies')
                          .doc(name);
                      DocumentSnapshot userDocSnapshot = await userDocRef.get();
                      if (userDocSnapshot.exists) {
                        Map<String, dynamic> userData =
                            userDocSnapshot.data() as Map<String, dynamic>;
                        email = userData['email'] as String;
                        final form = formKey.currentState!;
                        if (form.validate()) {}
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email, password: password);
                      }
                      else{
                        showErrorDialog(context, "Account not found");
                      }
                      //Navigator.of(context).pushNamed(logicRoute);
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        await showErrorDialog(context, 'User not found');
                      } else if (e.code == 'wrong-password') {
                        await showErrorDialog(context, 'Wrong password');
                      } else {
                        await showErrorDialog(context, 'Error: $e.code');
                      }
                    } catch (e) {
                      await showErrorDialog(context, e.toString());
                    }
                  },
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.blue,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Sign In",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Don't not have an account?",
                    style: TextStyle(fontSize: 15),
                  ),
                  TextButton(
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      //Navigator.of(context).pushNamed(registerRoute);
                    },
                  ),
                ],
              ),
              TextButton(
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 15),
                ),
                onPressed: () {
                  // Navigator.of(context).pushNamed(resetPasswordRoute);
                },
              ),
            ],
          ),
        ));
  }
}
