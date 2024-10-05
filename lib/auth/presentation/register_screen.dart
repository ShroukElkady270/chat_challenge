import 'dart:io';

import 'package:educatly_challenge/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;

  XFile? imageFile;

  _openGallery() async {
    var picture = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = XFile(picture!.path);
    });
  }

  _openCamera() async {
    var picture = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      imageFile = XFile(picture!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign up',
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
                obscureText: true,
                validator: (value) => value!.isEmpty
                    ? 'Invalid password'
                    : value.length < 6
                        ? 'Password must be more than 6 characters'
                        : null,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30.0),
              imageFile != null
                  ? Row(
                      children: [
                        const Spacer(),
                        SizedBox(
                          height: 100.0,
                          width: 100.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              60.0,
                            ),
                            child: Image.file(
                              File(imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            const Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 21.0,
                                              vertical: 7.0,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Colors.white,
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.white,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                20.0,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  blurRadius: 10.0,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                const SizedBox(height: 31.0),
                                                const Text(
                                                  'Choose uploading type',
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 35.0),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    border: Border.all(
                                                      color: Colors.white30,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10.0,
                                                    ),
                                                  ),
                                                  child: MaterialButton(
                                                    onPressed: () {
                                                      _openCamera();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 30.0,
                                                      ),
                                                      child: Text(
                                                        'Open Camera',
                                                        style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 21.0),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    border: Border.all(
                                                      color: Colors.white30,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10.0,
                                                    ),
                                                  ),
                                                  child: MaterialButton(
                                                    onPressed: () {
                                                      _openGallery();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 30.0,
                                                      ),
                                                      child: Text(
                                                        'Choose from Gallery',
                                                        style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 31.0),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.replay,
                                size: 30.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upload your avatar',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 21.0,
                                          vertical: 7.0,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          border: Border.all(
                                            width: 2,
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.white,
                                              blurRadius: 10.0,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const SizedBox(height: 31.0),
                                            const Text(
                                              'Choose uploading type',
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 35.0),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                border: Border.all(
                                                  color: Colors.white30,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: MaterialButton(
                                                onPressed: () {
                                                  _openCamera();
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 30.0,
                                                  ),
                                                  child: Text(
                                                    'Open Camera',
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 21.0),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                border: Border.all(
                                                  color: Colors.white30,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: MaterialButton(
                                                onPressed: () {
                                                  _openGallery();
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 30.0,
                                                  ),
                                                  child: Text(
                                                    'Choose from Gallery',
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 31.0),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(
                            Icons.upload,
                            size: 40.0,
                          ),
                        ),
                      ],
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
                          if (validateAndSave() && imageFile != null) {
                            setState(() {
                              isLoading = true;
                            });
                            context.read<AuthCubit>().register(
                                  _emailController.text,
                                  _passwordController.text,
                                  imageFile!,
                                  context,
                                );
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.0,
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
