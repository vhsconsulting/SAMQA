create index samqa.insure_n13 on
    samqa.insure (
        insurance_member_id
    );


-- sqlcl_snapshot {"hash":"9bdb9f67263e962ca14e91e3496f441f37981ec8","type":"INDEX","name":"INSURE_N13","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INSURE_N13</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INSURE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INSURANCE_MEMBER_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}