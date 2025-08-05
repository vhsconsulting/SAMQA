create index samqa.enterprise_n4 on
    samqa.enterprise (
        cobra_id_number
    );


-- sqlcl_snapshot {"hash":"0784c2bb0a5407483ac9c18fca8880688c5d82d2","type":"INDEX","name":"ENTERPRISE_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENTERPRISE_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENTERPRISE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>COBRA_ID_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}