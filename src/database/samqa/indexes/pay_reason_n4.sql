create index samqa.pay_reason_n4 on
    samqa.pay_reason (
        reason_mapping
    );


-- sqlcl_snapshot {"hash":"e4c7cd2acdc804cc2f4706a5fa2309fffa6d4d84","type":"INDEX","name":"PAY_REASON_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAY_REASON_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAY_REASON</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>REASON_MAPPING</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}