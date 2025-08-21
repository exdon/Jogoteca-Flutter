import 'package:flutter/material.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/widget/transicao.dart';

class AdultContentDialog {
  static void show(BuildContext context, Widget telaDestino) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          AppConstants.attentionTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppConstants.adultContentLogo, fit: BoxFit.cover),
              const Text(
                AppConstants.adultContentMessage,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 50),
              _buildCancelButton(context),
              _buildConfirmButton(context, telaDestino),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context, 'Cancel'),
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.cancelButtonColor),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          )
      ),
      child: const Text(AppConstants.cancelButton),
    );
  }

  static Widget _buildConfirmButton(BuildContext context, Widget telaDestino) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Transicao(telaDestino: telaDestino),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.confirmButtonColor),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          )
      ),
      child: const Text(AppConstants.confirmButton),
    );
  }
}