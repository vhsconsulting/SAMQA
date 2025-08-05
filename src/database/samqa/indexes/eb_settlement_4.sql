create index samqa.eb_settlement_4 on
    samqa.eb_settlement (
        acc_id
    );


-- sqlcl_snapshot {"hash":"77999e9ff55117fc2bd32141aefedb791b4c23e5","type":"INDEX","name":"EB_SETTLEMENT_4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EB_SETTLEMENT_4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EB_SETTLEMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}