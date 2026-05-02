import 'package:agro_pastoral_app/VU/gestion-exploitation/gestionexploitation.dart';
import 'package:agro_pastoral_app/models/gestion-compte/modeluser.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'VU/gestion-cheptel/gestion_cheptel.dart';
import 'VU/gestion-compte/vulogin.dart';
import 'VU/gestion-culture/vugestion_cultures.dart';
import 'gestion_rapp_stats.dart';
import 'VU/gestion-finance/vugestion_finances.dart';
import 'VU/gestion-stock/vugestion_stock.dart';
import 'VU/gestion-personnel/Personnel.dart';
import 'VU/gestion-alerte/Alerte.dart';

import 'soinscheptel.dart';
import 'activitéAgro.dart';
import 'providers/selectedexploitationprovider.dart';
import 'package:provider/provider.dart';



void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SelectedExploitationProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agro-Pastoral App',
      theme: ThemeData(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E9D2),
          selectedItemColor: Color(0xFF2E7D32),
          unselectedItemColor: Color(0xFF2E7D32),),
        colorScheme: ColorScheme(
          //Mode clair de l'application
            brightness: Brightness.light,
            //Couleur principal de l'application en vert foncé
            primary: Color(0xFF2E7D32),
            //couleur du texte sur le prymary
            onPrimary: Colors.white,
            // Couleur secondaires
            secondary: Color(0xFF66BB6A),
            //couleur du texte sur le Secondaire
            onSecondary: Colors.white,
            //Couleur des erreurs
            error: Colors.red,
            //Couleur texte a saisir pendant l'erreur
            onError: Colors.white,
            //couleur surface
            surface: Colors.white,
            //Couleur Texte surface
            onSurface: Color(0xFF263238),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Icon icon_notififation = Icon(Icons.notifications,color: Colors.white,);
  Icon icon_reglage = Icon(Icons.settings,color: Colors.white,);
  String affiche = '';
  int indexselect = 0;

  User get user => user;

  void indexclick(int index){
    setState(() {
      indexselect=index;
      switch(indexselect){
        case 0: Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context )=>MyCulturePage( code_expl: 0, )
            ));
        break;
        case 1:  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context )=>MyCheptelePage(title: '',)
            ));
        break;
        case 2:  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context )=>StockPage(user: user,)
            ));
        break;
        case 3:  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context )=>FinancePage()
            ));
        break;
        case 4:  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context )=>MyRappPage(title: '',)
            ));
        break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){}, icon: icon_notififation,color: Color(0xFF2E7D32),),
          IconButton(onPressed: (){}, icon: icon_reglage,color: Color(0xFF2E7D32)),

        ],
        iconTheme: IconThemeData(color: Color(0xFF2E7D32)),
        surfaceTintColor: Colors.transparent,

        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset("assets/images/logo.jpeg", width: 80,height: 95, fit: BoxFit.fill,),
            SizedBox(width: 10),

          ],
        ),
      ),
        body: Stack(
            children: <Widget>[
        // ce bloc cree le fond en image
        Container(
        decoration: BoxDecoration(
            image: DecorationImage(
            image: AssetImage("assets/images/logo.jpeg"),
        fit: BoxFit.cover, // COUVRE TT LE BODY)
        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
            ),
        ),
        ),
            ]
        ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedFontSize: 15.0,
        unselectedFontSize:15.0 ,
        backgroundColor: Color(0xFF1E9D2),
        selectedItemColor: Color(0xFF2E7D32),
        unselectedItemColor: Color(0xFF2E7D32),
        items: [
          BottomNavigationBarItem(
            tooltip: "la page de gestion des cultures",
            label: "Cultures",
            icon: Icon(Icons.grass,color: Color(0xFF2E7D32),),
          ),
          BottomNavigationBarItem(
            tooltip: "la page de gestion du cheptel",
            label: "Cheptel",
            icon: Icon(Icons.pets,color: Color(0xFF2E7D32),),
          ),
          BottomNavigationBarItem(
            tooltip: "la page de gestion des stocks",
            label: "Stocks",
            icon: Icon(Icons.inventory_2,color: Color(0xFF2E7D32),),
          ),
          BottomNavigationBarItem(
            tooltip: "la page de gestion des finances",
            label: "Finances",
            icon: Icon(Icons.account_balance_wallet,color: Color(0xFF2E7D32),),
          ),
          BottomNavigationBarItem(
            tooltip: "la page de gestion des rapports et statistiques",
            label: "Rapports et Stats",
            icon: Icon(Icons.bar_chart,color: Color(0xFF2E7D32),),
          ),
        ],
        onTap: indexclick,
        currentIndex: indexselect,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context)=>ExploitationPage(),));
          },
          backgroundColor: Color(0xFF2E7D32),
          elevation: 8,
          highlightElevation: 15,
          child: FaIcon(FontAwesomeIcons.add,color: Colors.white,),
          tooltip: 'Ajouter une nouvelle Exploitation',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      drawer: AppDrawer(userName: "DIOUF"),

      
    );
  }
}
class AppDrawer extends StatelessWidget {
  final String userName;

  const AppDrawer({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text("user@email.com"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          ListTile(
            leading: Icon(Icons.people),
            title: Text("Gestion du personnel"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PersonnelPage()));
            },
          ),

          ListTile(
            leading: Icon(Icons.warning),
            title: Text("Gestion des alertes"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  AlertePage ()),
              );
            },
          ),


          ListTile(
            leading: Icon(Icons.pets),
            title: Text("Soins du cheptel"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SoinscheptelPage(title: "",)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.eco),
            title: Text("Activités agronomiques"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ActivityagroPage(title: "",)),
              );
            },
          ),

          Divider(),

          // 🚪 Déconnexion
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Déconnexion"),
            onTap: () {
              Navigator.pop(context);
              // Ici tu pourras connecter ton AuthProvider plus tard
            },
          ),
        ],
      ),
    );
  }
}