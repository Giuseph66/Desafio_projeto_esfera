/// Modelo de dados para empresa/CNPJ
/// 
/// Representa tanto dados de consulta quanto dados salvos no banco
class Company {
  final String? id;
  final String cnpj;
  final String razaoSocial;
  final String? nomeFantasia;
  final String? situacaoCadastral;
  final DateTime? dataSituacaoCadastral;
  final String? matrizFilial;
  final DateTime? dataInicioAtividade;
  final String? cnaePrincipal;
  final List<String>? cnaesSecundarios;
  final int? cnaesSecundariosCount;
  final String? naturezaJuridica;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cep;
  final String? uf;
  final String? municipio;
  final String? email;
  final List<Map<String, dynamic>>? telefones;
  final double? capitalSocial;
  final String? porteEmpresa;
  final String? opcaoSimples;
  final DateTime? dataOpcaoSimples;
  final String? opcaoMei;
  final DateTime? dataOpcaoMei;
  final List<Map<String, dynamic>>? qsa;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const Company({
    this.id,
    required this.cnpj,
    required this.razaoSocial,
    this.nomeFantasia,
    this.situacaoCadastral,
    this.dataSituacaoCadastral,
    this.matrizFilial,
    this.dataInicioAtividade,
    this.cnaePrincipal,
    this.cnaesSecundarios,
    this.cnaesSecundariosCount,
    this.naturezaJuridica,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cep,
    this.uf,
    this.municipio,
    this.email,
    this.telefones,
    this.capitalSocial,
    this.porteEmpresa,
    this.opcaoSimples,
    this.dataOpcaoSimples,
    this.opcaoMei,
    this.dataOpcaoMei,
    this.qsa,
    this.createdAt,
    this.updatedAt,
  });
  
  /// Cria instância a partir de dados de consulta CNPJ
  factory Company.fromCnpjData(Map<String, dynamic> data) {
    return Company(
      cnpj: data['cnpj']?.toString() ?? '',
      razaoSocial: data['razao_social']?.toString() ?? '',
      nomeFantasia: data['nome_fantasia']?.toString(),
      situacaoCadastral: data['situacao_cadastral']?.toString(),
      dataSituacaoCadastral: data['data_situacao_cadastral'] != null 
          ? DateTime.tryParse(data['data_situacao_cadastral'].toString())
          : null,
      matrizFilial: data['matriz_filial']?.toString(),
      dataInicioAtividade: data['data_inicio_atividade'] != null 
          ? DateTime.tryParse(data['data_inicio_atividade'].toString())
          : null,
      cnaePrincipal: data['cnae_principal']?.toString(),
      cnaesSecundarios: data['cnaes_secundarios'] != null 
          ? List<String>.from(data['cnaes_secundarios'])
          : null,
      cnaesSecundariosCount: data['cnaes_secundarios_count']?.toInt(),
      naturezaJuridica: data['natureza_juridica']?.toString(),
      logradouro: data['logradouro']?.toString(),
      numero: data['numero']?.toString(),
      complemento: data['complemento']?.toString(),
      bairro: data['bairro']?.toString(),
      cep: data['cep']?.toString(),
      uf: data['uf']?.toString(),
      municipio: data['municipio']?.toString(),
      email: data['email']?.toString(),
      telefones: data['telefones'] != null 
          ? List<Map<String, dynamic>>.from(data['telefones'])
          : null,
      capitalSocial: data['capital_social'] != null 
          ? double.tryParse(data['capital_social'].toString().replaceAll(',', '.'))
          : null,
      porteEmpresa: data['porte_empresa']?.toString(),
      opcaoSimples: data['opcao_simples']?.toString(),
      dataOpcaoSimples: data['data_opcao_simples'] != null 
          ? DateTime.tryParse(data['data_opcao_simples'].toString())
          : null,
      opcaoMei: data['opcao_mei']?.toString(),
      dataOpcaoMei: data['data_opcao_mei'] != null 
          ? DateTime.tryParse(data['data_opcao_mei'].toString())
          : null,
      qsa: data['QSA'] != null 
          ? List<Map<String, dynamic>>.from(data['QSA'])
          : null,
    );
  }
  
  /// Cria instância a partir de dados salvos no banco
  factory Company.fromJson(Map<String, dynamic> data) {
    return Company(
      id: data['id']?.toString(),
      cnpj: data['cnpj']?.toString() ?? '',
      razaoSocial: data['razao_social']?.toString() ?? '',
      nomeFantasia: data['nome_fantasia']?.toString(),
      situacaoCadastral: data['situacao_cadastral']?.toString(),
      dataSituacaoCadastral: data['data_situacao_cadastral'] != null 
          ? DateTime.tryParse(data['data_situacao_cadastral'].toString())
          : null,
      matrizFilial: data['matriz_filial']?.toString(),
      dataInicioAtividade: data['data_inicio_atividade'] != null 
          ? DateTime.tryParse(data['data_inicio_atividade'].toString())
          : null,
      cnaePrincipal: data['cnae_principal_code']?.toString(),
      cnaesSecundarios: data['cnaes_secundarios'] != null 
          ? List<String>.from(data['cnaes_secundarios'])
          : null,
      cnaesSecundariosCount: data['cnaes_secundarios_count']?.toInt(),
      naturezaJuridica: data['natureza_juridica']?.toString(),
      logradouro: data['logradouro']?.toString(),
      numero: data['numero']?.toString(),
      complemento: data['complemento']?.toString(),
      bairro: data['bairro']?.toString(),
      cep: data['cep']?.toString(),
      uf: data['uf']?.toString(),
      municipio: data['municipio']?.toString(),
      email: data['email']?.toString(),
      telefones: data['telefones'] != null 
          ? List<Map<String, dynamic>>.from(data['telefones'])
          : null,
      capitalSocial: data['capital_social'] != null 
          ? double.tryParse(data['capital_social'].toString())
          : null,
      porteEmpresa: data['porte_empresa']?.toString(),
      opcaoSimples: data['opcao_simples']?.toString(),
      dataOpcaoSimples: data['data_opcao_simples'] != null 
          ? DateTime.tryParse(data['data_opcao_simples'].toString())
          : null,
      opcaoMei: data['opcao_mei']?.toString(),
      dataOpcaoMei: data['data_opcao_mei'] != null 
          ? DateTime.tryParse(data['data_opcao_mei'].toString())
          : null,
      qsa: data['qsa'] != null 
          ? List<Map<String, dynamic>>.from(data['qsa'])
          : null,
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString())
          : null,
      updatedAt: data['updated_at'] != null 
          ? DateTime.tryParse(data['updated_at'].toString())
          : null,
    );
  }
  
  /// Converte para JSON (para envio ao backend)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cnpj': cnpj,
      'razao_social': razaoSocial,
      if (nomeFantasia != null) 'nome_fantasia': nomeFantasia,
      if (situacaoCadastral != null) 'situacao_cadastral': situacaoCadastral,
      if (dataSituacaoCadastral != null) 'data_situacao_cadastral': dataSituacaoCadastral!.toIso8601String().split('T')[0],
      if (matrizFilial != null) 'matriz_filial': matrizFilial,
      if (dataInicioAtividade != null) 'data_inicio_atividade': dataInicioAtividade!.toIso8601String().split('T')[0],
      if (cnaePrincipal != null) 'cnae_principal_code': cnaePrincipal,
      if (cnaesSecundarios != null) 'cnaes_secundarios': cnaesSecundarios,
      if (cnaesSecundariosCount != null) 'cnaes_secundarios_count': cnaesSecundariosCount,
      if (naturezaJuridica != null) 'natureza_juridica': naturezaJuridica,
      if (logradouro != null) 'logradouro': logradouro,
      if (numero != null) 'numero': numero,
      if (complemento != null) 'complemento': complemento,
      if (bairro != null) 'bairro': bairro,
      if (cep != null) 'cep': cep,
      if (uf != null) 'uf': uf,
      if (municipio != null) 'municipio': municipio,
      if (email != null) 'email': email,
      if (telefones != null) 'telefones': telefones,
      if (capitalSocial != null) 'capital_social': capitalSocial,
      if (porteEmpresa != null) 'porte_empresa': porteEmpresa,
      if (opcaoSimples != null) 'opcao_simples': opcaoSimples,
      if (dataOpcaoSimples != null) 'data_opcao_simples': dataOpcaoSimples!.toIso8601String().split('T')[0],
      if (opcaoMei != null) 'opcao_mei': opcaoMei,
      if (dataOpcaoMei != null) 'data_opcao_mei': dataOpcaoMei!.toIso8601String().split('T')[0],
      if (qsa != null) 'qsa': qsa,
    };
  }
  
  /// Cria cópia com campos alterados
  Company copyWith({
    String? id,
    String? cnpj,
    String? razaoSocial,
    String? nomeFantasia,
    String? situacaoCadastral,
    DateTime? dataSituacaoCadastral,
    String? matrizFilial,
    DateTime? dataInicioAtividade,
    String? cnaePrincipal,
    List<String>? cnaesSecundarios,
    int? cnaesSecundariosCount,
    String? naturezaJuridica,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cep,
    String? uf,
    String? municipio,
    String? email,
    List<Map<String, dynamic>>? telefones,
    double? capitalSocial,
    String? porteEmpresa,
    String? opcaoSimples,
    DateTime? dataOpcaoSimples,
    String? opcaoMei,
    DateTime? dataOpcaoMei,
    List<Map<String, dynamic>>? qsa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      cnpj: cnpj ?? this.cnpj,
      razaoSocial: razaoSocial ?? this.razaoSocial,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
      situacaoCadastral: situacaoCadastral ?? this.situacaoCadastral,
      dataSituacaoCadastral: dataSituacaoCadastral ?? this.dataSituacaoCadastral,
      matrizFilial: matrizFilial ?? this.matrizFilial,
      dataInicioAtividade: dataInicioAtividade ?? this.dataInicioAtividade,
      cnaePrincipal: cnaePrincipal ?? this.cnaePrincipal,
      cnaesSecundarios: cnaesSecundarios ?? this.cnaesSecundarios,
      cnaesSecundariosCount: cnaesSecundariosCount ?? this.cnaesSecundariosCount,
      naturezaJuridica: naturezaJuridica ?? this.naturezaJuridica,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cep: cep ?? this.cep,
      uf: uf ?? this.uf,
      municipio: municipio ?? this.municipio,
      email: email ?? this.email,
      telefones: telefones ?? this.telefones,
      capitalSocial: capitalSocial ?? this.capitalSocial,
      porteEmpresa: porteEmpresa ?? this.porteEmpresa,
      opcaoSimples: opcaoSimples ?? this.opcaoSimples,
      dataOpcaoSimples: dataOpcaoSimples ?? this.dataOpcaoSimples,
      opcaoMei: opcaoMei ?? this.opcaoMei,
      dataOpcaoMei: dataOpcaoMei ?? this.dataOpcaoMei,
      qsa: qsa ?? this.qsa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modelo para dados paginados de empresas
class CompanyListResponse {
  final int total;
  final int page;
  final int pageSize;
  final List<Company> data;
  
  const CompanyListResponse({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.data,
  });
  
  factory CompanyListResponse.fromJson(Map<String, dynamic> data) {
    final List<dynamic> companiesData = data['data'] ?? [];
    
    return CompanyListResponse(
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['pageSize'] ?? 20,
      data: companiesData
          .map((companyData) => Company.fromJson(companyData as Map<String, dynamic>))
          .toList(),
    );
  }
}
