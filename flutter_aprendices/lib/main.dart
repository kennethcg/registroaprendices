import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final String supabaseUrl =
    'https://bzugtznonmknwzeiujxo.supabase.co'.replaceAll(' ', '');

const String supabasePublishableKey =
    'sb_publishable_iOuVTHoXegcK2whol_Afyw_DMN0uZFr';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aprendices',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}

// =====================================================
// AUTENTICACIÓN
// =====================================================

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool ocultarPassword = true;
  bool cargando = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } on AuthException catch (e) {
      mostrarMensaje(e.message);
    } catch (e) {
      mostrarMensaje('Error: $e');
    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> registrarUsuario() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.length < 6) {
      mostrarMensaje(
        'Ingresa un correo y una contraseña de mínimo 6 caracteres',
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final respuesta = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      if (respuesta.session == null) {
        mostrarMensaje(
          'Usuario creado. Revisa tu correo para confirmar la cuenta.',
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } on AuthException catch (e) {
      mostrarMensaje(e.message);
    } catch (e) {
      mostrarMensaje('Error: $e');
    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Icon(
                      Icons.school,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'APRENDICES',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Formulario de autenticación',
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: ocultarPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              ocultarPassword = !ocultarPassword;
                            });
                          },
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cargando ? null : iniciarSesion,
                        child: Text(
                          cargando ? 'Cargando...' : 'INICIAR SESIÓN',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: cargando ? null : registrarUsuario,
                      child: const Text(
                        'Crear cuenta',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// HOMEPAGE
// =====================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> aprendices = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarAprendices();
  }

  // ===================================================
  // READ
  // ===================================================

  Future<void> cargarAprendices() async {
    setState(() {
      cargando = true;
    });

    try {
      final respuesta = await supabase.from('aprendiz').select().order('id');

      setState(() {
        aprendices = List<Map<String, dynamic>>.from(respuesta);
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });

      mostrarMensaje(
        'Error cargando aprendices: $e',
      );
    }
  }

  // ===================================================
  // DELETE
  // ===================================================

  Future<void> eliminarAprendiz(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar aprendiz',
          ),
          content: Text(
            '¿Seguro que deseas eliminar el aprendiz con ID $id?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await supabase.from('aprendiz').delete().eq('id', id);

      mostrarMensaje(
        'Aprendiz eliminado correctamente',
      );

      cargarAprendices();
    } catch (e) {
      mostrarMensaje(
        'Error eliminando: $e',
      );
    }
  }

  // ===================================================
  // LOGOUT
  // ===================================================

  Future<void> cerrarSesion() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  String nombreCompleto(
    Map<String, dynamic> aprendiz,
  ) {
    return [
      aprendiz['nombre1'],
      aprendiz['nombre2'],
      aprendiz['apellido1'],
      aprendiz['apellido2'],
    ]
        .where(
          (dato) => dato != null && dato.toString().trim().isNotEmpty,
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Aprendices',
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargarAprendices,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          abrirFormulario();
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Nuevo aprendiz',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: cargando
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : aprendices.isEmpty
                ? const Center(
                    child: Text(
                      'No hay aprendices registrados',
                    ),
                  )
                : ListView.builder(
                    itemCount: aprendices.length,
                    itemBuilder: (context, index) {
                      final aprendiz = aprendices[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              '${aprendiz['id']}',
                            ),
                          ),
                          title: Text(
                            nombreCompleto(aprendiz),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Correo: ${aprendiz['email']}\n'
                            'Celular: ${aprendiz['celular']}\n'
                            'Género: ${aprendiz['genero']}\n'
                            'Nacimiento: ${aprendiz['fecha_nacimiento']}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                onPressed: () {
                                  abrirFormulario(
                                    aprendiz,
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                onPressed: () {
                                  eliminarAprendiz(
                                    aprendiz['id'],
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  // ===================================================
  // FORMULARIO
  // ===================================================

  Future<void> abrirFormulario([Map<String, dynamic>? aprendiz]) async {
    await showDialog(
      context: context,
      builder: (context) {
        return FormularioAprendiz(
          aprendiz: aprendiz,
          actualizar: cargarAprendices,
        );
      },
    );
  }
}

// =====================================================
// FORMULARIO APRENDIZ
// =====================================================

class FormularioAprendiz extends StatefulWidget {
  final Map<String, dynamic>? aprendiz;
  final VoidCallback actualizar;

  const FormularioAprendiz({
    super.key,
    required this.aprendiz,
    required this.actualizar,
  });

  @override
  State<FormularioAprendiz> createState() => _FormularioAprendizState();
}

class _FormularioAprendizState extends State<FormularioAprendiz> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController id;
  late TextEditingController nombre1;
  late TextEditingController nombre2;
  late TextEditingController apellido1;
  late TextEditingController apellido2;
  late TextEditingController fechaNacimiento;
  late TextEditingController celular;
  late TextEditingController email;

  String genero = 'M';

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    final aprendiz = widget.aprendiz;

    id = TextEditingController(
      text: '${aprendiz?['id'] ?? ''}',
    );

    nombre1 = TextEditingController(
      text: '${aprendiz?['nombre1'] ?? ''}',
    );

    nombre2 = TextEditingController(
      text: '${aprendiz?['nombre2'] ?? ''}',
    );

    apellido1 = TextEditingController(
      text: '${aprendiz?['apellido1'] ?? ''}',
    );

    apellido2 = TextEditingController(
      text: '${aprendiz?['apellido2'] ?? ''}',
    );

    fechaNacimiento = TextEditingController(
      text: '${aprendiz?['fecha_nacimiento'] ?? ''}',
    );

    celular = TextEditingController(
      text: '${aprendiz?['celular'] ?? ''}',
    );

    email = TextEditingController(
      text: '${aprendiz?['email'] ?? ''}',
    );

    if (aprendiz?['genero'] != null) {
      genero = aprendiz!['genero'].toString();
    }
  }

  @override
  void dispose() {
    id.dispose();
    nombre1.dispose();
    nombre2.dispose();
    apellido1.dispose();
    apellido2.dispose();
    fechaNacimiento.dispose();
    celular.dispose();
    email.dispose();

    super.dispose();
  }

  // ===================================================
  // FECHA
  // ===================================================

  Future<void> seleccionarFecha() async {
    DateTime fechaInicial = DateTime.tryParse(
          fechaNacimiento.text,
        ) ??
        DateTime(2000, 1, 1);

    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (fechaSeleccionada != null) {
      final mes = fechaSeleccionada.month.toString().padLeft(2, '0');

      final dia = fechaSeleccionada.day.toString().padLeft(2, '0');

      fechaNacimiento.text = '${fechaSeleccionada.year}-$mes-$dia';

      setState(() {});
    }
  }

  // ===================================================
  // CREATE / UPDATE
  // ===================================================

  Future<void> guardar() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final idNumero = int.tryParse(id.text.trim());

    if (idNumero == null) {
      mostrarMensaje(
        'El ID debe ser un número',
      );
      return;
    }

    setState(() {
      guardando = true;
    });

    final datos = {
      'id': idNumero,
      'nombre1': nombre1.text.trim(),
      'nombre2': nombre2.text.trim().isEmpty ? null : nombre2.text.trim(),
      'apellido1': apellido1.text.trim(),
      'apellido2': apellido2.text.trim().isEmpty ? null : apellido2.text.trim(),
      'genero': genero,
      'fecha_nacimiento': fechaNacimiento.text.trim(),
      'celular': celular.text.trim(),
      'email': email.text.trim(),
    };

    try {
      if (widget.aprendiz == null) {
        // CREATE
        await supabase.from('aprendiz').insert(datos);

        mostrarMensaje(
          'Aprendiz creado correctamente',
        );
      } else {
        // UPDATE
        await supabase.from('aprendiz').update(datos).eq('id', idNumero);

        mostrarMensaje(
          'Aprendiz actualizado correctamente',
        );
      }

      widget.actualizar();

      if (mounted) {
        Navigator.pop(context);
      }
    } on PostgrestException catch (e) {
      mostrarMensaje(
        'Error de Supabase: ${e.message}',
      );
    } catch (e) {
      mostrarMensaje(
        'Error: $e',
      );
    }

    if (mounted) {
      setState(() {
        guardando = false;
      });
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  String? validarCampo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obligatorio';
    }

    return null;
  }

  Widget campo(
    String titulo,
    TextEditingController controller, {
    TextInputType? tipo,
    bool obligatorio = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        validator: obligatorio ? validarCampo : null,
        decoration: InputDecoration(
          labelText: titulo,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editar = widget.aprendiz != null;

    return AlertDialog(
      title: Text(
        editar ? 'Editar aprendiz' : 'Nuevo aprendiz',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                campo(
                  'ID',
                  id,
                  tipo: TextInputType.number,
                ),
                campo(
                  'Primer nombre',
                  nombre1,
                ),
                campo(
                  'Segundo nombre',
                  nombre2,
                  obligatorio: false,
                ),
                campo(
                  'Primer apellido',
                  apellido1,
                ),
                campo(
                  'Segundo apellido',
                  apellido2,
                  obligatorio: false,
                ),
                DropdownButtonFormField<String>(
                  value: genero,
                  decoration: const InputDecoration(
                    labelText: 'Género',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'M',
                      child: Text('Masculino'),
                    ),
                    DropdownMenuItem(
                      value: 'F',
                      child: Text('Femenino'),
                    ),
                    DropdownMenuItem(
                      value: 'O',
                      child: Text('Otro'),
                    ),
                  ],
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() {
                        genero = valor;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fechaNacimiento,
                  readOnly: true,
                  validator: validarCampo,
                  onTap: seleccionarFecha,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(
                      Icons.calendar_month,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                campo(
                  'Celular',
                  celular,
                  tipo: TextInputType.phone,
                ),
                campo(
                  'Correo electrónico',
                  email,
                  tipo: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: guardando
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text(
            'Cancelar',
          ),
        ),
        ElevatedButton.icon(
          onPressed: guardando ? null : guardar,
          icon: const Icon(
            Icons.save,
          ),
          label: Text(
            guardando ? 'Guardando...' : 'Guardar',
          ),
        ),
      ],
    );
  }
}
