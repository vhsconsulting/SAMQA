create index samqa.employer_divisions_n3 on
    samqa.employer_divisions (
        division_main
    );


-- sqlcl_snapshot {"hash":"26b9c3107ff38e6177ade88f6da7d844e970d91d","type":"INDEX","name":"EMPLOYER_DIVISIONS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_DIVISIONS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_DIVISIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>DIVISION_MAIN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}