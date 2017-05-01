lf:{system["l /home/michael/projects/modq/modq.q"];}
//@########################################UTILITY FUNCTIONS########################################@//
/@Function Name| .kdb.util.safeEval
/@Description  | Apply supplied params to the supplied function and throw an error along with the kdb+ error
/@Params       | func<-11h> paramList<list>
/@Example      | .kdb.util.safeEval[`funcName;(2;"a")]
.kdb.util.safeEval:{[func;paramList]
 errFunc:{.kdb.priv.log.tryLog["Error: \n\tFunction: ",x,"\n\tkdb+ error:",y];}[string[func];];
 fn:value func;
 nparam:count(value fn)[1];
 .[fn;nparam#paramList;errFunc]
 }
//@######################################DEVELOPMENT FUNCTIONS######################################@//
/@Function Name| .kdb.dev.mline
/@Description  | Allow multi-line code to be PASTED in the q console. Type STOP to disable.
/@Params       | toggleOpt<-11h>
/@Example      | .kdb.dev.mline[`on]
.kdb.dev.mline:{[toggleOpt]
 valid:any `on`off=r:first toggleOpt;
 if[not valid;'"Invalid toggleOpt. Options are `on or `off";];
 /tell the user
 .kdb.priv.log.tryLog["You have toggled multiline mode ",string[r]];
 $[r~`on;
   [.kdb.misc.clearScreen[];
    .kdb.priv.log.tryLog["You can now paste a multi-line valid q function to the terminal.\nWhen you are done type 'STOP' and hit enter."];
    `.z.pi set .kdb.priv.dev.zpi;
   ];
   .kdb.misc.resetFunc[".z.pi"]];
 }
/@Function Name| .kdb.dev.streamList
/@Description  | Investigate a list or table etc (something that can be indexed by number)
/@Params       | rows<-7h> list
/@Example      | .kdb.dev.streamList[40;100?([]times:10?.z.T;syms:10?`3)]
.kdb.dev.streamList:{[rows;list] {.kdb.misc.clearScreen[];show y[z+x];system["sleep 0.1"]}[til rows;list;]each til 1+count list;}
/@Function Name| .kdb.dev.insertBreak
/@Description  | Insert break statement as the first statement to be executed in a user defined function
/@Params       | func<100h 104h>
/@Example      | .kdb.dev.insertBreak[.kdb.log.init]
.kdb.dev.insertBreak:{f:string[x];value raze@[$[f[1]~"[";1+first where f~\:"]";1] cut f;0;,;" stop;"]}
//@####################################MISCELLANEOUS FUNCTIONS########################################@//
/@Function Name| .kdb.misc.commaFmt
/@Description  | For a given number, return the number as a comma formated string
/@Params       | number<-5 -6 -7 -8 -9h>
/@Example      | .kdb.misc.commaFmt each `a`b`c`d`e!`float`real`long`int`short$1000
.kdb.misc.commaFmt:{reverse csv sv 3 cut reverse string x}
/@Function Name| .kdb.misc.formatDate
/@Description  | Formats kdb+ date to pretty date
/@Params       | dateList<14h> delim<-10h 10h>
/@Example      | update niceDate:.kdb.misc.formatDate[dates;"-"] from ([]dates:10?.z.D)
.kdb.misc.formatDate:{z sv/:flip@[flip "."vs'string y;1;x]}[("0"^-2$string[1+til 12])!string`Jan`Feb`Mar`Apr`May`Jun`Jul`Aug`Sept`Oct`Nov`Dec;;]
/@Function Name| .kdb.misc.resetFunc
/@Description  | Reset function to the default q definition
/@Params       | funcName<10h>
/@Example      | .kdb.misc.resetFunc[".z.pi"]
.kdb.misc.resetFunc:{system["x ",x];}
/@Function Name| .kdb.misc.clearScreen
/@Description  | Clear the screen
/@Params       | None
/@Example      | .kdb.misc.clearScreen[]
.kdb.misc.clearScreen:{-1"\033[H\033[2J";}
/@Function Name| .kdb.misc.help
/@Description  | Show information about all of the functions defined in this script
/@Params       | None
/@Example      | .kdb.misc.help[]
.kdb.misc.help:{
 -1 .kdb.priv.misc.info;
 }
//@########################################LOGGING FUNCTIONS########################################@//
/@Function Name| .kdb.log.init
/@Description  | Initialise logging functionality
/@Params       | logType<`console|`file|`both> opts<-11h>
/@Example      | .kdb.log.init[`file;`:/path/to/logFile.log]
.kdb.log.init:{[logType;opts]
 if[not any `both`console`file=logType:first logType;'"Invalid logType. Options are `console or `file or `both";];
 smsg:"Logging has been enabled. LogType: ",string[logType];
 .kdb.priv.log.logType:logType;
 if[`console~logType;.kdb.priv.log.logging:1b;.kdb.log.logm smsg;:()];
 fileOptsOK:all(any `file`both in logType;-11h~type opts;":"~first 1#string[opts]);
 $[fileOptsOK;
   [.kdb.priv.log.logH:hopen[opts];.kdb.priv.log.logging:1b;.kdb.log.logm smsg];
   '"Invalid opts. If logType is `file then opts must be hsym i.e. `:/path/to/logFile.log"];
 }
/@Function Name| .kdb.log.logm
/@Description  | Log a message to the console, file or both. Depending on logging initialisation
/@Params       | logmessage<10h>
/@Example      | .kdb.log.logm "Starting the weekly loading process."
.kdb.log.logm:{
 if[not .kdb.priv.log.logging;'"Logging has not been enabled. See .kdb.log.init";];
 msg:" - "sv (x,"@",y;string[.z.T];z);
 write:{neg[.kdb.priv.log.logH]x;};
 $[`file~.kdb.priv.log.logType;
   write msg;
   `both~.kdb.priv.log.logType;
   [write msg;-1 msg];
   -1 msg
 ];
 }[string[.z.u];string[.z.h];]
//@########################################PRIVATE FUNCTIONS########################################@//
.kdb.priv.log.logging:0b
.kdb.priv.log.logH:0Ni
.kdb.priv.log.tryLog:{
 $[.kdb.priv.log.logging;.kdb.log.logm[x];-1 x];
 }
.kdb.priv.dev.zpi:{
 inp:-1 _x;
 if[inp~"STOP";
    @[value;"\n"sv .kdb.priv.dev.inp;{.kdb.priv.log.tryLog["Not a valid function"]}];
    .kdb.priv.dev.inp:();
    .kdb.dev.mline`off;
    :();];
 .kdb.priv.dev.inp,:enlist inp;
 .kdb.misc.clearScreen[];
 -1 ("\n"sv .kdb.priv.dev.inp),"\n";
 }
.kdb.priv.misc.buildinfo:{
 info:"\n\n"sv "\n"sv'4 cut 2_'script where max(3#'script:read0 x)~\:/:("/@",/:"FDPE");
 system["c 100 2000"];
 fh:hopen x;
 neg[fh][".kdb.priv.misc.info:",-3!info];
 hclose fh;
 }
/intro message
-1 "\n\tAll functions are defined within the .kdb namespace.\n\tView .kdb.misc.help[] for a full list of functions.";
.kdb.priv.misc.info:"Function Name| .kdb.util.safeEval\nDescription  | Apply supplied params to the supplied function and throw an error along with the kdb+ error\nParams       | func<-11h> paramList<list>\nExample      | .kdb.util.safeEval[`funcName;(2;\"a\")]\n\nFunction Name| .kdb.dev.mline\nDescription  | Allow multi-line code to be PASTED in the q console. Type STOP to disable.\nParams       | toggleOpt<-11h>\nExample      | .kdb.dev.mline[`on]\n\nFunction Name| .kdb.dev.insertBreak\nDescription  | Insert break statement as the first statement to be executed in a user defined function\nParams       | func<100h 104h>\nExample      | .kdb.dev.insertBreak[`.kdb.log.init]\n\nFunction Name| .kdb.misc.commaFmt\nDescription  | For a given number, return the number as a comma formated string\nParams       | number<-5 -6 -7 -8 -9h>\nExample      | .kdb.misc.commaFmt each `a`b`c`d`e!`float`real`long`int`short$1000\n\nFunction Name| .kdb.misc.formatDate\nDescription  | Formats kdb+ date to pretty date\nParams       | dateList<14h> delim<-10h 10h>\nExample      | update niceDate:.kdb.misc.formatDate[dates;\"-\"] from ([]dates:10?.z.D)\n\nFunction Name| .kdb.misc.resetFunc \nDescription  | Reset function to the default q definition\nParams       | funcName<10h>\nExample      | .kdb.misc.resetFunc[\".z.pi\"]\n\nFunction Name| .kdb.misc.clearScreen\nDescription  | Clear the screen\nParams       | None\nExample      | .kdb.misc.clearScreen[]\n\nFunction Name| .kdb.misc.help\nDescription  | Show information about all of the functions defined in this script\nParams       | None\nExample      | .kdb.misc.help[]\n\nFunction Name| .kdb.log.init\nDescription  | Initialise logging functionality\nParams       | logType<`console|`file|`both> opts<-11h>\nExample      | .kdb.log.init[`file;`:/path/to/logFile.log]"
