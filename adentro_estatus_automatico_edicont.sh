#!/usr/bin/sh
cd /appl/kbpp01/utils/Menu/doc013031/EDICONTR/
rm salida_edi_seleccion_ping.txt 
rm salida_edi_estatus_crontab.txt
rm pingnok.temp
#----------------------------
#   Rutinas 
#----------------------------
R=`pwd`
DIA=`date '+%d/%m/20%y'`; HORA=`date '+%H:%M:%S'`
ANO=`date '+20%y'`
MES=`date '+%m'`
Hora=$(date +%r)
SER=`uname -a | awk '{print $2}'`


RUTINA_MENSAJE () {
    echo " "
    echo " "
    echo ""
    echo " Administracion de Plataformas Integradas                                                                        Ruta  :   $R "
    echo " Gerencia Sistema de Gestion Empresarial                                                                         Fecha :   $DIA "
    echo " Gerencia de Ingenieria, desarrollo y Construccion TI/SI                                                         Hora  :   $Hora "
    echo " Gerencia General de Tecnologia y Operaciones                                                                    Servidor: $SER "
    echo ""
    echo "===================================="
    echo "  ESTATUS DIARIO EDI CONTROLLER     "
    echo "===================================="
}

#####-------------------------------
RUTINA_IMPRESION () {

#-------------------------
echo "Buenos Dias"
echo "Se Anexa Estatus Diario edi con"
echo " "
echo "Saludos Cordiales"
echo "                                    controller Estatus Diario"


#--------------------------
echo ""
#titulo="PING SERVIDORES "
echo "#----------------------------------#"
echo "#        PING SERVIDORES           #"
echo "#----------------------------------#"
RUTINA_PING () {
cont=0
cd /appl/kbpp01/utils/Menu/doc013031/EDICONTR/
/usr/sbin/ping $servidor -n 6 | awk '{print $6}' > time_"$servidor".txt
                for linea in $(cat time_"$servidor".txt)
                do
                 if [ "$linea" = "time=0." ] || [ "$linea" = "time=1." ] || [ "$linea" = "time=2."  ] || [ "$linea" = "time=3." ] ||
                    [ "$linea" = "time=4." ] || [ "$linea" = "time=5." ] || [ "$linea" = "time=6."  ] || [ "$linea" = "time=7." ] ||
                    [ "$linea" = "time=8." ] || [ "$linea" = "time=9." ] || [ "$linea" = "time=10." ] ; then
                      cont=`expr $cont + 1`
                 fi
                done
                if [ "$cont" = 6  ]; then
                   echo "Tiempo de Respuesta Servidor " $servidor "OK"
                   else
                   echo "Tiempo de Respuesta Servidor " $servidor "NOT OK"
                fi
}
cd /appl/kbpp01/utils/Menu/doc013031/EDICONTR/
for servidor in $(cat Matriz_Servidor_edi.txt)
    do
        RUTINA_PING $servidor
	RUTINA_PING $servidor >> salida_edi_seleccion_ping.txt
    done
rm time_*.txt

cd /appl/kbpp01/utils/Menu/doc013031/EDICONTR/
grep "NOT OK" salida_edi_seleccion_ping.txt  > pingnok.temp
cont1=`cat pingnok.temp | wc -l`
#echo "$cont1 "
if  [ $cont1 -gt 0 ];    #si es mayor que
    then
       echo "#####                               #####                              ##### "
       echo "#####      ATENCION:  Se debe chequear ya que existe Servidores Caidos ##### "
       cat pingnok.temp
       mailx -s "ATENCION EXISTEN SERVIDORES CAIDOS EN EDI-CONTROLLER $DIA "  alejo24175@gmail.com apere7@cantv.com.ve < pingnok.temp
    else
       echo " "
       echo "           #####          PING  SERVIDORES ACTIVOS  ...   ##### "
fi

#FIN DE RUTINA IMPRESION
}



clear
echo "===================================="
echo " IMPRESION                          "
echo "===================================="
echo "En Proceso Gardando en archivo: salida_estatus_crontab_edix.txt Tarda:Aproximadamente 1 Minuto" 
RUTINA_IMPRESION > salida_edi_estatus_crontab.txt
clear
echo "Termine puede revisar la salida "
#rm kk.temp1
mailx -s "Adminfac01 Estatus Diario $DIA "  apere7@cantv.com.ve < salida_edi_estatus_crontab.txt
