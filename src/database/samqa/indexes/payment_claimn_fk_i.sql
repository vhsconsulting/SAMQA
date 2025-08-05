create index samqa.payment_claimn_fk_i on
    samqa.payment (
        claimn_id
    );


-- sqlcl_snapshot {"hash":"e36d6425145f62fde7528ebc6b98be08668cde31","type":"INDEX","name":"PAYMENT_CLAIMN_FK_I","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAYMENT_CLAIMN_FK_I</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAYMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIMN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}