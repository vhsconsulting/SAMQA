create index samqa.person_n8 on
    samqa.person ( reverse(acc_numc) );


-- sqlcl_snapshot {"hash":"7d85ec95f4903bc268934ee54282516cb3323ecd","type":"INDEX","name":"PERSON_N8","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PERSON_N8</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PERSON</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>REVERSE(\"ACC_NUMC\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}