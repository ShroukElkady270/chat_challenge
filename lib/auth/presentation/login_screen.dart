import 'package:educatly_challenge/auth/presentation/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                ),
              ),
              const SizedBox(height: 60.0),
              TextFormField(
                controller: _emailController,
                validator: (value) => value!.isEmpty ? 'Invalid email' : null,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                controller: _passwordController,
                validator: (value) => value!.isEmpty
                    ? 'Invalid password'
                    : value.length < 6
                        ? 'Password must be more than 6 characters'
                        : null,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40.0),
              isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white30,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          if (validateAndSave()) {
                            setState(() {
                              isLoading = true;
                            });
                            context.read<AuthCubit>().login(
                                  _emailController.text,
                                  _passwordController.text,
                                  context,
                                );
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.0,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have account?',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
