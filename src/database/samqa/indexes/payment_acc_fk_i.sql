create index samqa.payment_acc_fk_i on
    samqa.payment (
        acc_id
    );


-- sqlcl_snapshot {"hash":"c2d0ea51a5ae2d1683756b98b577b2d5aaefbb3c","type":"INDEX","name":"PAYMENT_ACC_FK_I","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAYMENT_ACC_FK_I</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAYMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}