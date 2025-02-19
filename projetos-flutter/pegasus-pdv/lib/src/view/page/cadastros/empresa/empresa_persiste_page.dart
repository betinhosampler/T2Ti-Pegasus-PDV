/*
Title: T2Ti ERP 3.0                                                                
Description: PersistePage relacionada à tabela [EMPRESA] 
                                                                                
The MIT License                                                                 
                                                                                
Copyright: Copyright (C) 2021 T2Ti.COM                                          
                                                                                
Permission is hereby granted, free of charge, to any person                     
obtaining a copy of this software and associated documentation                  
files (the "Software"), to deal in the Software without                         
restriction, including without limitation the rights to use,                    
copy, modify, merge, publish, distribute, sublicense, and/or sell               
copies of the Software, and to permit persons to whom the                       
Software is furnished to do so, subject to the following                        
conditions:                                                                     
                                                                                
The above copyright notice and this permission notice shall be                  
included in all copies or substantial portions of the Software.                 
                                                                                
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,                 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES                 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                        
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT                     
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,                    
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING                    
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR                   
OTHER DEALINGS IN THE SOFTWARE.                                                 
                                                                                
       The author may be contacted at:                                          
           t2ti.com@gmail.com                                                   
                                                                                
@author Albert Eije (alberteije@gmail.com)                    
@version 1.0.0
*******************************************************************************/
// import 'dart:io';
import 'dart:typed_data';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:pegasus_pdv/src/database/database_classes.dart';

import 'package:pegasus_pdv/src/infra/infra.dart';
import 'package:pegasus_pdv/src/infra/atalhos_desktop_web.dart';
import 'package:pegasus_pdv/src/model/cadastros/empresa_model.dart';
import 'package:pegasus_pdv/src/service/service.dart';
import 'package:pegasus_pdv/src/view/login/registro_page.dart';

import 'package:pegasus_pdv/src/view/shared/dropdown_lista.dart';
import 'package:pegasus_pdv/src/view/shared/view_util_lib.dart';
import 'package:pegasus_pdv/src/view/shared/caixas_de_dialogo.dart';
import 'package:pegasus_pdv/src/view/shared/botoes.dart';
import 'package:pegasus_pdv/src/view/shared/widgets_input.dart';


class EmpresaPersistePage extends StatefulWidget {
  final String? title;
  final String? operacao;

  const EmpresaPersistePage({Key? key, this.title, this.operacao})
      : super(key: key);

  @override
  _EmpresaPersistePageState createState() => _EmpresaPersistePageState();
}

class _EmpresaPersistePageState extends State<EmpresaPersistePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  // final ImagePicker _pickerImagem = ImagePicker();

  Map<LogicalKeySet, Intent>? _shortcutMap; 
  Map<Type, Action<Intent>>? _actionMap;
  final _foco = FocusNode();

  // final _imagemController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _nomeFantasiaController = TextEditingController();
  final _emailController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _cnpjController = MaskedTextController(mask: Constantes.mascaraCNPJ);
  final _telefoneController = MaskedTextController(mask: Constantes.mascaraTELEFONE);
  final _cepController = MaskedTextController(mask: Constantes.mascaraCEP);
  final _ibgeController = MaskedTextController(mask: '0000000');

  List<EmpresaCnae> _listaCnae = [];
  
  @override
  void initState() {
    super.initState();
    bootstrapGridParameters(
      gutterSize: Constantes.flutterBootstrapGutterSize,
    );
    _shortcutMap = getAtalhosPersistePage();
    _actionMap = <Type, Action<Intent>>{
      AtalhoTelaIntent: CallbackAction<AtalhoTelaIntent>(
        onInvoke: _tratarAcoesAtalhos,
      ),
    };
    _foco.requestFocus();

    WidgetsBinding.instance!.addPostFrameCallback((_) => _consultarCnae());
  }

  Future _consultarCnae() async {
    await Sessao.db.empresaCnaeDao.consultarLista();
    setState(() {
    });
  }

  void _tratarAcoesAtalhos(AtalhoTelaIntent intent) {
    switch (intent.type) {
      case AtalhoTelaType.salvar:
        _salvar();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _telefoneController.text = Sessao.empresa?.fone ?? '';
    _cepController.text = Sessao.empresa?.cep ?? '';
    _cnpjController.text = Sessao.empresa?.cnpj ?? '';
    _razaoSocialController.text = Sessao.empresa?.razaoSocial ?? '';
    _nomeFantasiaController.text = Sessao.empresa?.nomeFantasia ?? '';
    _emailController.text = Sessao.empresa?.email ?? '';
    _logradouroController.text = Sessao.empresa?.logradouro ?? '';
    _numeroController.text = Sessao.empresa?.numero ?? '';
    _bairroController.text = Sessao.empresa?.bairro ?? '';
    _complementoController.text = Sessao.empresa?.complemento ?? '';
    _cidadeController.text = Sessao.empresa?.cidade ?? '';
    _ibgeController.text = Sessao.empresa?.codigoIbgeCidade?.toString() ?? '';

    _listaCnae = Sessao.db.empresaCnaeDao.listaEmpresaCnae;

    return FocusableActionDetector(
      actions: _actionMap,
      shortcuts: _shortcutMap,
      child: Focus(
        autofocus: true,
        child: WillPopScope(
          onWillPop: () async => false,
            child: Scaffold(drawerDragStartBehavior: DragStartBehavior.down,
            key: _scaffoldKey,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Dados da Empresa'), 
              actions: getBotoesAppBarPersistePage(context: context, salvar: _salvar,),
            ),      
            body: SafeArea(
              top: false,
              bottom: false,
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    dragStartBehavior: DragStartBehavior.down,
                    child: BootstrapContainer(
                      fluid: true,
                      decoration: const BoxDecoration(color: Colors.white),
                      padding: Biblioteca.isTelaPequena(context) == true ? ViewUtilLib.paddingBootstrapContainerTelaPequena : ViewUtilLib.paddingBootstrapContainerTelaGrande,                    // children: [
                      children: <Widget>[			  			  
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12 col-md-3',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: InputDecorator(
                                  decoration: getInputDecoration(
                                    'Tipo Empresa (Matriz ou Filial)',
                                    'Tipo Empresa',
                                    true),
                                  isEmpty: Sessao.empresa!.tipo == null,
                                  child: getDropDownButton(Sessao.empresa!.tipo,
                                    (String? newValue) {
                                      setState(() {
                                        Sessao.empresa = Sessao.empresa!.copyWith(tipo: newValue);
                                      });
                                  }, <String>[
                                    'Matriz',
                                    'Filial',
                                ])),
                              ),
                            ),
                            BootstrapCol(
                              sizes: 'col-12 col-md-9',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  focusNode: _foco,
                                  maxLength: 18,
                                  validator: ValidaCampoFormulario.validarObrigatorioCNPJ,
                                  keyboardType: TextInputType.number,
                                  controller: _cnpjController,
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo CNPJ',
                                    'CNPJ',
                                    true,
                                    paddingVertical: 18),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) async {
                                    if (_cnpjController.text.length == 18) {
                                      await _atualizarDadosPeloCnpj();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12',
                              child: TextFormField(
                                validator: ValidaCampoFormulario.validarObrigatorio,
                                maxLength: 150,
                                maxLines: 1,
                                controller: _nomeFantasiaController,
                                decoration: getInputDecoration(
                                  'Conteúdo para o campo Fantasia',
                                  'Fantasia',
                                  false),
                                onSaved: (String? value) {
                                },
                                onChanged: (text) {
                                  Sessao.empresa = Sessao.empresa!.copyWith(nomeFantasia: text);
                                },
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: Sessao.configuracaoPdv!.modulo != 'G',
                          child: const Divider(color: Colors.white,),
                        ),
                        Visibility(
                          visible: Sessao.configuracaoPdv!.modulo != 'G',
                          child: BootstrapRow(
                            height: 60,
                            children: <BootstrapCol>[
                              BootstrapCol(
                                sizes: 'col-12',
                                child: InputDecorator(
                                  decoration: getInputDecoration(
                                    'Selecione a Opção Desejada',
                                    'CRT',
                                    true),
                                  isEmpty: Sessao.empresa!.crt == null,
                                  child: getDropDownButton(Sessao.empresa!.crt,
                                    (String? newValue) {
                                      setState(() {
                                        Sessao.empresa = Sessao.empresa!.copyWith(crt: newValue);
                                      });
                                      }, <String>[
                                        '1-Simples Nacional',
                                        '2-Simples Nacional - excesso de sublimite da receita bruta',
                                        '3-Regime Normal',
                                      ],
                                      validator: ValidaCampoFormulario.validarObrigatorio,
                                    )
                                  ),							
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  validator: ValidaCampoFormulario.validarObrigatorio,
                                  maxLength: 150,
                                  maxLines: 1,
                                  controller: _razaoSocialController,
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Razao Social',
                                    'Razao Social',
                                    true,
                                    paddingVertical: 15),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) {
                                    Sessao.empresa = Sessao.empresa!.copyWith(razaoSocial: text);
                                  },
                                ),
                              ),
                            ),
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: InputDecorator(
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Data Constituição',
                                    'Data Constituição',
                                    true),
                                  isEmpty: Sessao.empresa!.dataConstituicao == null,
                                  child: DatePickerItem(
                                    mascara: 'dd/MM/yyyy',
                                    dateTime: Sessao.empresa!.dataConstituicao,
                                    firstDate: DateTime.parse('1900-01-01'),
                                    lastDate: DateTime.now(),
                                    onChanged: (DateTime? value) {
                                      setState(() {
                                        Sessao.empresa = Sessao.empresa!.copyWith(dataConstituicao: value);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  validator: Sessao.configuracaoPdv!.modulo != 'G' 
                                    ? ValidaCampoFormulario.validarObrigatorio 
                                    : null,
                                  maxLength: 30,
                                  maxLines: 1,
                                  initialValue: Sessao.empresa?.inscricaoEstadual ?? '',
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Inscricao Estadual',
                                    'Inscricao Estadual',
                                    false),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) {
                                    Sessao.empresa = Sessao.empresa!.copyWith(inscricaoEstadual: text);
                                  },
                                ),
                              ),
                            ),
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  maxLength: 30,
                                  maxLines: 1,
                                  initialValue: Sessao.empresa?.inscricaoMunicipal ?? '',
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Inscricao Municipal',
                                    'Inscricao Municipal',
                                    false),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) {
                                    Sessao.empresa = Sessao.empresa!.copyWith(inscricaoMunicipal: text);
                                 },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12',
                              child: TextFormField(
                                validator: ValidaCampoFormulario.validarObrigatorioEmail,
                                maxLength: 250,
                                maxLines: 3,
                                controller: _emailController,
                                decoration: getInputDecoration(
                                  'Conteúdo para o campo Email',
                                  'Email',
                                  false),
                                onSaved: (String? value) {
                                },
                                onChanged: (text) {
                                  Sessao.empresa = Sessao.empresa!.copyWith(email: text);
                                },
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12',
                              child: TextFormField(
                                validator: Sessao.configuracaoPdv!.modulo != 'G' 
                                  ? ValidaCampoFormulario.validarObrigatorio 
                                  : null,
                                maxLength: 250,
                                maxLines: 3,
                                controller: _logradouroController,
                                decoration: getInputDecoration(
                                  'Conteúdo para o campo Logradouro',
                                  'Logradouro',
                                  false),
                                onSaved: (String? value) {
                                },
                                onChanged: (text) {
                                  Sessao.empresa = Sessao.empresa!.copyWith(logradouro: text);
                                },
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  validator: Sessao.configuracaoPdv!.modulo != 'G' 
                                    ? ValidaCampoFormulario.validarObrigatorio 
                                    : null,
                                  maxLength: 10,
                                  maxLines: 1,
                                  controller: _numeroController,
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Numero',
                                    'Numero',
                                    true,
                                    paddingVertical: 18),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) {
                                    Sessao.empresa = Sessao.empresa!.copyWith(numero: text);
                                  },
                                ),
                              ),
                            ),
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: InputDecorator(
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Uf',
                                    'Uf',
                                    true),
                                  isEmpty: Sessao.empresa?.uf == null,
                                  child: getDropDownButton(Sessao.empresa!.uf,
                                    (String? newValue) {
                                      setState(() {
                                        Sessao.empresa = Sessao.empresa!.copyWith(uf: newValue);
                                      });
                                  }, 
                                  DropdownLista.listaUF,
                                  validator: Sessao.configuracaoPdv!.modulo != 'G' 
                                    ? ValidaCampoFormulario.validarObrigatorio 
                                    : null,
                                  )),                                                      
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12',
                              child: TextFormField(
                                maxLength: 100,
                                maxLines: 1,
                                controller: _complementoController,
                                decoration: getInputDecoration(
                                  'Conteúdo para o campo Complemento',
                                  'Complemento',
                                  false),
                                onSaved: (String? value) {
                                },
                                onChanged: (text) {
                                  Sessao.empresa = Sessao.empresa!.copyWith(complemento: text);
                                },
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  validator: Sessao.configuracaoPdv!.modulo != 'G' 
                                    ? ValidaCampoFormulario.validarObrigatorio 
                                    : null,
                                  maxLength: 100,
                                  maxLines: 1,
                                  controller: _bairroController,
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Bairro',
                                    'Bairro',
                                    false),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) {
                                    Sessao.empresa = Sessao.empresa!.copyWith(bairro: text);
                                  },
                                ),
                              ),
                            ),
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  validator: Sessao.configuracaoPdv!.modulo != 'G' 
                                    ? ValidaCampoFormulario.validarObrigatorio 
                                    : null,
                                  maxLength: 100,
                                  maxLines: 1,
                                  controller: _cidadeController,
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Cidade',
                                    'Cidade',
                                    false),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) {
                                    Sessao.empresa = Sessao.empresa!.copyWith(cidade: text);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  validator: Sessao.configuracaoPdv!.modulo != 'G' 
                                    ? ValidaCampoFormulario.validarObrigatorio 
                                    : null,
                                  keyboardType: TextInputType.number,
                                  controller: _cepController,
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Cep',
                                    'Cep',
                                    false,  ),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) {
                                    Sessao.empresa = Sessao.empresa!.copyWith(cep: Biblioteca.removerMascara(text));
                                  },
                                ),
                              ),
                            ),
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextFormField(
                                        validator: Sessao.configuracaoPdv!.modulo != 'G' 
                                          ? ValidaCampoFormulario.validarObrigatorioNumerico 
                                          : null,
                                        maxLength: 7,
                                        maxLines: 1,
                                        controller: _ibgeController,
                                        decoration: getInputDecoration(
                                          'Conteúdo para o campo IBGE Município',
                                          'Código Município IBGE',
                                          false),
                                        onSaved: (String? value) {
                                        },
                                        onChanged: (text) {
                                          Sessao.empresa = Sessao.empresa!.copyWith(codigoIbgeCidade: int.tryParse(text));
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: IconButton(
                                        tooltip: 'Importar IBGE',
                                        icon: ViewUtilLib.getIconBotaoLookup(),
                                        onPressed: () async {
                                          for (var i = 0; i < Sessao.tabelaMunicipios.length; i++) {
                                            if (Sessao.tabelaMunicipios[i][3] == _cidadeController.text //nome_caixa_alta
                                             || Sessao.tabelaMunicipios[i][3].toString().toLowerCase() == _cidadeController.text.toLowerCase()
                                             || Sessao.tabelaMunicipios[i][4] == _cidadeController.text //nome_cursivo - com acentos
                                             || Sessao.tabelaMunicipios[i][4].toString().toLowerCase() == _cidadeController.text.toLowerCase()
                                            ) {
                                              _ibgeController.text = Sessao.tabelaMunicipios[i][0].toString();
                                            }
                                          }        
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _telefoneController,
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Telefone',
                                    'Telefone',
                                    false),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) {
                                    Sessao.empresa = Sessao.empresa!.copyWith(fone: Biblioteca.removerMascara(text));
                                  },
                                ),
                              ),
                            ),
                            BootstrapCol(
                              sizes: 'col-12 col-md-6',
                              child: Padding(
                                padding: Biblioteca.distanciaEntreColunasQuebraLinha(context)!,
                                child: TextFormField(
                                  maxLength: 50,
                                  maxLines: 1,
                                  initialValue: Sessao.empresa?.contato ?? '',
                                  decoration: getInputDecoration(
                                    'Conteúdo para o campo Contato',
                                    'Contato',
                                    false),
                                  onSaved: (String? value) {
                                  },
                                  onChanged: (text) {
                                    Sessao.empresa = Sessao.empresa!.copyWith(contato: text);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(color: Colors.white,),
                        const Padding(
                          padding: EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 0),
                          child: Text(
                            "Logotipo", 
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black
                            ),
                          ),
                        ),
                        const Divider(
                          indent: 10,
                          endIndent: 10,
                          thickness: 2,
                        ),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12',
                              child: CarregaImagem(
                                widgetFilho: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  height: 200,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Image.memory(Sessao.empresa!.logotipo!),
                                  ),
                                ), 
                                exibirImagemCallBack: _exibirImagem,
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     _exibirImagemPicker(context);
                              //   },                            
                              //   child: Container(
                              //     margin: const EdgeInsets.symmetric(horizontal: 10),
                              //     height: 200,
                              //     child: FittedBox(
                              //       fit: BoxFit.contain,
                              //       child: 
                              //       Image.memory(Sessao.empresa!.logotipo!),                                  
                              //     ),
                              //   ),
                              // ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white,),
                        const Padding(
                          padding: EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 0),
                          child: Text(
                            "CNAEs vinculados à empresa", 
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ),
                        const Divider(
                          indent: 10,
                          endIndent: 10,
                          thickness: 2,
                        ),

                        SizedBox(
                          height: 170.0,
                          child: Scrollbar(
                            child: ListView(
                              padding: const EdgeInsets.all(2.0),
                              children: <Widget>[
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 2.0,
                                    child:
                                    DataTable(
                                      columns: getColumnsCnae(),
                                      rows: getRowsCnae()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              child: getBotaoGenericoPdv(
                                descricao: 'Consultar CNAEs',
                                cor: Colors.blue, 
                                onPressed: () async {
                                  await _atualizarDadosPeloCnpj();
                                }
                              ),
                            ), 
                          ],
                        ),

                        const Divider(
                          indent: 10,
                          endIndent: 10,
                          thickness: 2,
                        ),

                        const Divider(color: Colors.white,),
                        BootstrapRow(
                          height: 60,
                          children: <BootstrapCol>[
                            BootstrapCol(
                              sizes: 'col-12',
                              child: 
                                Text(
                                  '* indica que o campo é obrigatório',
                                  style: Theme.of(context).textTheme.caption,
                                ),								
                            ),
                          ],
                        ),
                        Visibility(
                          visible: Sessao.empresa!.registrado ?? false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: getBotaoGenericoPdv(
                                  descricao: 'Alterar Opção MEI',
                                  cor: Colors.green, 
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                      showDialog(
                                        context: context, 
                                        builder: (BuildContext context){
                                          return const RegistroPage(title: 'Registro do Usuário');
                                        })
                                        .then((_) {
                                        });
                                  }
                                ),
                              ), 
                              const SizedBox(
                                width: 10,
                              ), 
                              SizedBox(
                                width: 200,
                                child: getBotaoGenericoPdv(
                                  descricao: 'Sair sem Salvar',
                                  cor: Colors.red, 
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }
                                ),
                              ), 
                            ],
                          ),
                        ),
                        const SizedBox(height: 50.0),
                      ],
                    ),
                  ),
                ),			  
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> getColumnsCnae() {
    List<DataColumn> lista = [];
    lista.add(const DataColumn(
      label: Text(
        "Código",
        style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ));
    lista.add(const DataColumn(
      label: Text(
        "Descrição",
        style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ));
    lista.add(const DataColumn(
      numeric: true,
      label: Text(
        "Principal",
        style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ));
    return lista;
  }

  List<DataRow> getRowsCnae() {
    List<DataRow> lista = [];
    for (var cnae in _listaCnae) {
      List<DataCell> celulas = [];

      celulas = [
        DataCell(
          Text(cnae.codigo!),
        ),
        DataCell(
          Text(cnae.descricao!)
        ),          
        DataCell(
          Text(cnae.principal!)
        ),          
      ];
      lista.add(DataRow(cells: celulas));
    }
    return lista;
  }

  Future _atualizarDadosPeloCnpj() async {
    EmpresaService servico = EmpresaService();
    final empresaModel = await servico.consultarObjetoPublico(Biblioteca.removerMascara(_cnpjController.text));

    if (empresaModel != null) {
      Sessao.empresa = 
        Sessao.empresa!.copyWith(
          cnpj: Biblioteca.removerMascara(empresaModel.cnpj),
          nomeFantasia: empresaModel.fantasia,
          razaoSocial: empresaModel.nome,
          dataConstituicao: DateTime.tryParse(empresaModel.abertura!),
          // email: empresaModel.email,
          cep: empresaModel.cep!.replaceAll('.', ''),
          uf: empresaModel.uf,
          logradouro: empresaModel.logradouro,
          numero: empresaModel.numero,
          bairro: empresaModel.bairro,
          complemento: empresaModel.complemento,
          cidade: empresaModel.municipio,
          tipo: empresaModel.tipo == 'MATRIZ' ? 'M' : 'F',
          naturezaJuridica: empresaModel.naturezaJuridica,
        );
      await Sessao.db.empresaDao.alterar(Sessao.empresa!, true);

      // atualiza CNAE
      _listaCnae = [];
      for (var cnae in empresaModel.listaAtividadePrincipal) {
        EmpresaCnae empresCnae = EmpresaCnae(id: null, codigo: cnae.codigo, descricao: cnae.descricao, principal: 'S');
        _listaCnae.add(empresCnae);
      }
      for (var cnae in empresaModel.listaAtividadeSecundaria) {
        EmpresaCnae empresCnae = EmpresaCnae(id: null, codigo: cnae.codigo, descricao: cnae.descricao, principal: 'N');
        _listaCnae.add(empresCnae);
      }
      await Sessao.db.empresaCnaeDao.excluirTodos();
      await Sessao.db.empresaCnaeDao.inserirTodos(_listaCnae);
      Sessao.empresa = await Sessao.db.empresaDao.consultarObjeto(1);
      await _consultarCnae();
      setState(() {
      });
    } else {
      showInSnackBar('Ocorreu um problema ao tentar consultar os dados da empresa no Servidor.', context, corFundo: Colors.red);
    }
  }

  void _exibirImagem(Uint8List data) {
    setState(() {
      Sessao.empresa = Sessao.empresa!.copyWith(logotipo: data);
    });  
    Navigator.of(context).pop();
  }

  Future<void> _salvar() async {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      _autoValidate = AutovalidateMode.always;
      showInSnackBar(Constantes.mensagemCorrijaErrosFormSalvar, context);
    } else {
      gerarDialogBoxConfirmacao(context, Constantes.perguntaSalvarAlteracoes, () async {
        Sessao.empresa = Sessao.empresa!.copyWith(
          codigoIbgeUf: Biblioteca.retornarCodigoIbgeUf(Sessao.empresa!.uf),
        ); 
        form.save();
        // if (Sessao.configuracaoPdv.modulo != 'G') {
          EmpresaModel? empresa = EmpresaModel.fromDB(Sessao.empresa!);
          EmpresaService servico = EmpresaService();
          gerarDialogBoxEspera(context);
          empresa = await (servico.atualizar(empresa));        
          Sessao.fecharDialogBoxEspera(context);
          if (empresa != null) {
            await _salvarDadosLocais();
          } else {
            showInSnackBar('Ocorreu um problema ao tentar salvar os dados da empresa no Servidor.', context, corFundo: Colors.red);
          }
        // } else {
        //   await _salvarDadosLocais();
        // }
      });
    }
  }

  Future _salvarDadosLocais() async {
    await Sessao.db.empresaDao.alterar(Sessao.empresa!, Sessao.configuracaoPdv!.modulo != 'G');
    Sessao.empresa = await Sessao.db.empresaDao.consultarObjeto(1);
    showInSnackBar('Dados salvos com sucesso.', context, corFundo: Colors.blue);
    Navigator.of(context).pop();
  }

  // void _exibirImagemPicker(context) {
  //   _imagemController.text = '';
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext bc) {
  //       return SafeArea(
  //         child: Wrap(
  //           children: _getOpcoesImportacaoImagem(),
  //         ),
  //       );
  //     }
  //   );
  // }

  // List<Widget> _getOpcoesImportacaoImagem() {
  //   List<Widget> listaRetorno = [];
  //   listaRetorno.add(
  //     ListTile(
  //       leading: const Padding( 
  //         padding: EdgeInsets.all(5),
  //         child: Icon(Icons.cloud_download),
  //       ),
  //       title: _getEditUrl(), 
  //       onTap: () async {
  //         try {
  //           final ByteData imageData = await NetworkAssetBundle(Uri.parse(_imagemController.text)).load('');
  //           setState(() {
  //             Sessao.empresa = Sessao.empresa!.copyWith(logotipo: imageData.buffer.asUint8List());
  //           });
  //           Navigator.pop(context);
  //         } catch (e) {
  //           Navigator.pop(context);
  //           showInSnackBar('Ocorreu um erro ao tentar carregar a imagem', context);
  //         }
  //       }
  //     ),
  //   );
  //   listaRetorno.add(
  //     ListTile(
  //       leading: const Icon(Icons.file_copy),
  //       title: const Text('Carregar Imagem'),
  //       onTap: () async {
  //         // Documentação: https://github.com/miguelpruivo/flutter_file_picker/wiki
  //         FilePickerResult? arquivoSelecionado = 
  //           await FilePicker.platform.pickFiles(
  //             type: FileType.custom, 
  //             allowedExtensions: ['jpg, png'],
  //             dialogTitle: 'Selecione o Logotipo da Empresa'
  //           );
  //           if(arquivoSelecionado != null) {
  //             File file = File(arquivoSelecionado.files.first.path!);
  //             setState(() {
  //               Sessao.empresa = Sessao.empresa!.copyWith(logotipo: file.readAsBytesSync());
  //             });  
  //             Navigator.pop(context);
  //           }                          
  //       },
  //     ),        
  //   );

  //   if (Biblioteca.isMobile()) {
  //     listaRetorno.add(
  //       ListTile(
  //         leading: const Icon(Icons.photo_library),
  //         title: const Text('Galeria de Imagens'),
  //         onTap: () {
  //           _getImagemGaleria();
  //           Navigator.of(context).pop();
  //         }
  //       ),       
  //     );
  //     listaRetorno.add(
  //       ListTile(
  //         leading: const Icon(Icons.photo_camera),
  //         title: const Text('Câmera'),
  //         onTap: () {
  //           _getImagemCamera();
  //           Navigator.of(context).pop();
  //         },
  //       ),        
  //     );
  //   }
  //   return listaRetorno;
  // }
  
  // _getImagemCamera() async {
  //   final pickedFile = await _pickerImagem.pickImage(
  //     source: ImageSource.camera, imageQuality: 50
  //   );
  //   Sessao.empresa = Sessao.empresa!.copyWith(
  //     logotipo: await pickedFile?.readAsBytes(),
  //   );
  //   setState(() {
  //   });
  // }

  // _getImagemGaleria() async {
  //   final pickedFile = await _pickerImagem.pickImage(
  //     source: ImageSource.gallery, imageQuality: 50
  //   );
  //   if (pickedFile != null) {
  //     Sessao.empresa = Sessao.empresa!.copyWith(
  //       logotipo: await pickedFile.readAsBytes(),
  //     );
  //     setState(() {
  //     });
  //   }
  // }

  // Widget _getEditUrl() {
  //   return Column(
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
  //         child: TextFormField(
  //           controller: _imagemController,
  //           decoration: getInputDecoration(
  //             'Informe a URL para a imagem',
  //             'URL da Imagem',
  //             true),
  //           onChanged: (text) {
  //           },
  //         ),
  //       ),
  //     ],
  //   );   
  // }


}