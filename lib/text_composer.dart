import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMenssage);

  final Function({String text, File imgFile}) sendMenssage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  
  
  final TextEditingController _controller = TextEditingController();
  
  bool _isComposing = false;

  void reset(){
    _controller.clear();
      setState(() {
        _isComposing = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal:8),
      child: Row(
        children: <Widget>[
          IconButton(icon: Icon(Icons.photo_camera),
          onPressed: ()async {
            final File imgFile = await ImagePicker.pickImage(source: ImageSource.gallery);
            if(imgFile == null){
              return;
              }
            else{
            widget.sendMenssage(imgFile: imgFile);
            }
          },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMenssage(text: text);
                reset();
              },
            ),
          ),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposing ? () {
                widget.sendMenssage(text: _controller.text);
                reset();
              } : null)
        ],
      ),
    );
  }
}