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


#---------------------
# Saludos segun hora #
#---------------------
hora=`date +%R | cut -d ':' -f 1`
if [ $hora -ge 1 -a $hora -lt 12 ]
    then
       var1sa="Buenos Dias"
    elif [ $hora -ge 12 -a $hora -lt 18 ]
         then
       var1sa="Buenas Tardes"
    else
       var1sa="Buenas Noches"
fi


#####-------------------------------
RUTINA_IMPRESION () {

#-------------------------
echo "$var1sa"
#echo "Buenos Dias"
echo "Se Anexa Estatus Diario EDI-CONTROLLER"
echo "Saludos Cordiales"
echo "                      EDI-Estatus Diario"


#--------------------------
echo ""
#titulo="PING SERVIDORES "
echo "#----------------------------------#"
echo "#        PING SERVIDORES           #"
echo "#----------------------------------#"
rm pingnok_mensual.temp
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
cat pingnok.temp > pingnok_mensual.temp
cont1=`cat pingnok.temp | wc -l`
#echo "$cont1 "
if  [ $cont1 -gt 0 ];    #si es mayor que
    then
       echo "#####                               #####                              ##### "
       echo "#####      ATENCION:  Se debe chequear ya que existe Servidores Caidos ##### "
       cat pingnok.temp
       cat pingnok_mensual.temp  | xargs -n1 -i sh -c 'echo `date +%Y-%m-%d\ %H-%M-%S`" {}"'  >> muestra_salida_historico_ping_edi_mensual.txt
       mailx -s "ATENCION EXISTEN SERVIDORES CAIDOS EN EDI-CONTROLLER $DIA "  alejo24175@gmail.com maikerhenr@gmail.com fritne23@gmail.com < pingnok.temp
    else
       echo " "
       echo "  #####      SERVIDORES ACTIVOS  ...   ##### "
fi

#FIN DE RUTINA IMPRESION
}



clear
echo "===================================="
echo " IMPRESION                          "
echo "===================================="
echo "En Proceso Gardando en archivo: salida_estatus_crontab_edix.txt Tarda:Aproximadamente 1 Minuto" 
RUTINA_IMPRESION > salida_edi_estatus_crontab.txt  2> salida_errores_EDI.txt
clear
echo "Termine puede revisar la salida "
#rm kk.temp1
mailx -s "EDI-CONTROLLER - Estatus Diario $DIA "  apere7@cantv.com.ve maikerhenr@gmail.com fritne23@gmail.com equibi@cantv.com.ve  < salida_edi_estatus_crontab.txt
