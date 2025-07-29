create index samqa.broker_commission_register_u1 on
    samqa.broker_commission_register (
        change_num
    );


-- sqlcl_snapshot {"hash":"f7d4bff70dafaa7c490ef5e077091afa51332fd3","type":"INDEX","name":"BROKER_COMMISSION_REGISTER_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BROKER_COMMISSION_REGISTER_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BROKER_COMMISSION_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CHANGE_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}