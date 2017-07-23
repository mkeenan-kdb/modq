/This script parses the function descriptions defined in modq.q and appends them to the bottom of the script. This can then be shown to the user as useful help information
//GLOBALS
MOD_SCRIPT:hsym`$"/home/michael/q/projects/modq/modqORIG.q"
TEMP_SCRIPT:hsym`$"/home/michael/q/projects/modq/modq_documented.q"
//TODO delete below line - for dev
ds:{hdel TEMP_SCRIPT;}
//UTILS
logm:{-1@" - "sv (x,"@",y;string[.z.T];z);}[string[.z.u];string[.z.h];]
//LOGIC
document:{
 ds[];
 logm"Reading source modq script ",string MOD_SCRIPT; 
 raw:read0 MOD_SCRIPT;
 logm"Opening handle and pushing code to temporary script ",string TEMP_SCRIPT;
 ts:hopen TEMP_SCRIPT;
 neg[ts]($[all null first last[raw]ss ".kdb.priv.misc.info";raw;-1_raw]);
 logm"Parsing script info and appending to temp script";
 oc:system["c"];
 system["c 20 2000"];
 data:(".kdb.priv.misc.info:",-3!"\n"sv raze each 4 cut(2_'raw where(2#'raw)~\:"/@"),\:"\n");
 {neg[x](y)}[ts;]each (50 cut),\:"\\";
 logm"Done. The documentation has been added to the bottom of the temp script (",string[TEMP_SCRIPT],")";
 logm"Please check the script and replace the original if the result is appropriate";
 }
document[]
