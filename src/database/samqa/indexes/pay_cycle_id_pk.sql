create unique index samqa.pay_cycle_id_pk on
    samqa.pay_cycle_stage (
        pay_cycle_id
    );


-- sqlcl_snapshot {"hash":"1f954f9f599a49ff1c70405c7e187fdd88ec8720","type":"INDEX","name":"PAY_CYCLE_ID_PK","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAY_CYCLE_ID_PK</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAY_CYCLE_STAGE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PAY_CYCLE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}