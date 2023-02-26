import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'show_error_dialog.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('companies');
  late final TextEditingController passwordController;
  late final TextEditingController emailController;
  late final TextEditingController usernameController;
  bool _isObscure = true;

  final formKey = GlobalKey<FormState>();
  void validator(emailController) =>
      emailController != null && !EmailValidator.validate(emailController)
          ? 'Enter a valid email'
          : null;

  @override
  void initState() {
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.lightBlue),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder(
              future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              ),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    //  final user = FirebaseAuth.instance.currentUser;
                    return ListView(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'Health Watch',
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
                              'Register',
                              style: TextStyle(fontSize: 20),
                            )),
                        Form(
                          key: formKey,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: TextField(
                              autofillHints: const [AutofillHints.email],
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: TextField(
                            autofillHints: const [AutofillHints.username],
                            autocorrect: false,
                            keyboardType: TextInputType.name,
                            controller: usernameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              labelText: 'Company Name',
                              prefixIcon: Icon(Icons.person),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
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
                                      : Icons.visibility_off),
                                )),
                          ),
                        ),
                        Container(
                          height: 60,
                          padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                String email = emailController.text;
                                String name = usernameController.text;
                                String password = passwordController.text;
                                final form = formKey.currentState!;
                                if (form.validate()) {}
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: email, password: password);
                                Map<String, dynamic> userData = {
                                  email: email,
                                  name: name,
                                  password: password
                                };
                                usersCollection.doc(name).set(userData);
                                //Navigator.of(context).pushNamed(logicRoute);
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  await showErrorDialog(context,
                                      'Weak password : Password should be above 6 characters');
                                } else if (e.code == 'invalid-email') {
                                  await showErrorDialog(
                                      context, 'Invalid password');
                                } else if (e.code == 'email-already-in-use') {
                                  await showErrorDialog(context,
                                      'Email belongs to other user: Register with a different email');
                                } else {
                                  await showErrorDialog(
                                      context, 'Error: e.code');
                                }
                              } on TypeError catch (e) {
                                await showErrorDialog(context, e.toString());
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
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Get Started",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  default:
                    return const Text("Loading....");
                }
              })),
    );
  }
}
