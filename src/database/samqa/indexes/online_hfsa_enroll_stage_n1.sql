create index samqa.online_hfsa_enroll_stage_n1 on
    samqa.online_hfsa_enroll_stage (
        ssn
    );


-- sqlcl_snapshot {"hash":"20ea38e5a52a6ce066dd3155f2084752621034bf","type":"INDEX","name":"ONLINE_HFSA_ENROLL_STAGE_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_HFSA_ENROLL_STAGE_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_HFSA_ENROLL_STAGE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}