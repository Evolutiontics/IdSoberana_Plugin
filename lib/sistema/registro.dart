import 'dart:math';

class Registro {
  dynamic logId = [];
  int cuentaActual = 0;
  final elMax = 253; // 253
  final elMin = 200; // 200
  int globalId = 0;

  void crear(){
    logId = [];
    for(int i = 0; i <= elMax; i++){
      logId.add({'id':i+2,'nuevo':true});
    }
  }

  void cargar (dynamic ids){
    logId = ids;
  }

  int obtenerId(){
    final random = Random();

    int left = 0;
    logId.forEach((lId){
      if( lId['nuevo'] == false ){
        left++;
      }
    });
    cuentaActual = left;
    // Si ya ha entregado la mayoria de ids, debe volver a solicitar ids
    if((left-1) >= (elMax)){
      return -1;
    }

    bool buc = true;
    int idRnd = 0;
    do{
      int idn = random.nextInt(elMax+1);
      if(logId[idn]['nuevo'] == true){
        globalId = idn;
        logId[idn]['nuevo'] = false;
        idRnd = logId[idn]['id'];
        buc = false;
      }
    }while(buc);

    return idRnd;
  }
}
