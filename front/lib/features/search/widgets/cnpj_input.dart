import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/utils/cnpj.dart';

/// Campo de entrada para CNPJ com máscara e validação
/// 
/// Aplica máscara ##.###.###/####-## e aceita apenas dígitos
class CnpjInput extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  
  const CnpjInput({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
  });
  
  @override
  State<CnpjInput> createState() => _CnpjInputState();
}

class _CnpjInputState extends State<CnpjInput> {
  late TextEditingController _controller;
  late MaskTextInputFormatter _maskFormatter;
  
  @override
  void initState() {
    super.initState();
    _maskFormatter = MaskTextInputFormatter(
      mask: '##.###.###/####-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    _controller = widget.controller ?? TextEditingController();
  }
  
  @override
  void didUpdateWidget(CnpjInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? TextEditingController();
    }
  }
  
  @override
  void dispose() {
    // Só descarta o controller se foi criado internamente
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      inputFormatters: [_maskFormatter],
      keyboardType: TextInputType.number,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: 'CNPJ',
        hintText: '00.000.000/0000-00',
        errorText: widget.errorText,
        prefixIcon: const Icon(Icons.business),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged?.call('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB), // outline
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB), // outline
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2240FE), // primary
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626), // error
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626), // error
            width: 1.5,
          ),
        ),
      ),
      onChanged: (value) {
        widget.onChanged?.call(value);
      },
      onFieldSubmitted: (_) {
        widget.onSubmitted?.call();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'CNPJ é obrigatório';
        }
        
        final digitos = CnpjUtils.apenasDigitos(value);
        if (digitos.length != 14) {
          return 'CNPJ deve ter 14 dígitos';
        }
        
        if (!CnpjUtils.temDigitosVerificadoresValidos(digitos)) {
          return 'CNPJ inválido';
        }
        
        return null;
      },
    );
  }
}
