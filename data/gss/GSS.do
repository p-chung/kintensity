#delimit ;

   infix
      year     1 - 20
      unaunum  21 - 40
      grkidnum 41 - 60
      grparnum 61 - 80
      palive   81 - 100
      malive   101 - 120
      palive1  121 - 140
      malive1  141 - 160
      madeath  161 - 180
      padeath  181 - 200
      childs   201 - 220
      sibs     221 - 240
      id_      241 - 260
      ballot   261 - 280
using GSS.dat;

label variable year     "Gss year for this respondent                       ";
label variable unaunum  "Number of aunts and uncles";
label variable grkidnum "Number of adult grandchildren";
label variable grparnum "Number of grandparents";
label variable palive   "Father still alive?";
label variable malive   "Mother still alive?";
label variable palive1  "R father alive";
label variable malive1  "R mother alive";
label variable madeath  "Death of mother";
label variable padeath  "Death of father";
label variable childs   "Number of children";
label variable sibs     "Number of brothers and sisters";
label variable id_      "Respondent id number";
label variable ballot   "Ballot used for interview";


label define gsp001x
   99       "No answer"
   98       "Don't know"
   97       "# dk but > 0"
   96       "96 or more"
   -1       "Not applicable"
;
label define gsp002x
   99       "No answer"
   98       "Don't know"
   97       "# dk but > 0"
   96       "96 or more"
   -1       "Not applicable"
;
label define gsp003x
   99       "No answer"
   98       "Don't know"
   97       "# dk but > 0"
   96       "96 or more"
   -1       "Not applicable"
;
label define gsp004x
   9        "No answer"
   8        "Don't know"
   2        "No"
   1        "Yes"
   0        "Not applicable"
;
label define gsp005x
   9        "No answer"
   8        "Don't know"
   2        "No"
   1        "Yes"
   0        "Not applicable"
;
label define gsp006x
   9        "No answer"
   8        "Don't know"
   2        "No"
   1        "Yes"
   0        "Not applicable"
;
label define gsp007x
   9        "No answer"
   8        "Don't know"
   2        "No"
   1        "Yes"
   0        "Not applicable"
;
label define gsp008x
   9        "No answer"
   8        "Cant tell"
   4        "Died last year"
   3        "Died  1-5 yrs ago"
   2        "Died 6+ yrs ago"
   1        "Died before r 16"
   0        "No death reported"
   -1       "Not applicable"
;
label define gsp009x
   9        "No answer"
   8        "Cant tell"
   4        "Died last year"
   3        "Died  1-5 yrs ago"
   2        "Died 6+ yrs ago"
   1        "Died before r 16"
   0        "No death reported"
   -1       "Not applicable"
;
label define gsp010x
   9        "Dk na"
   8        "Eight or more"
;
label define gsp011x
   99       "No answer"
   98       "Don't know"
   -1       "Not applicable"
;
label define gsp012x
   4        "Ballot d"
   3        "Ballot c"
   2        "Ballot b"
   1        "Ballot a"
   0        "Not applicable"
;


label values unaunum  gsp001x;
label values grkidnum gsp002x;
label values grparnum gsp003x;
label values palive   gsp004x;
label values malive   gsp005x;
label values palive1  gsp006x;
label values malive1  gsp007x;
label values madeath  gsp008x;
label values padeath  gsp009x;
label values childs   gsp010x;
label values sibs     gsp011x;
label values ballot   gsp012x;


