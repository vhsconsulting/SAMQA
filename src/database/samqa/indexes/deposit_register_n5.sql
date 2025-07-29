create index samqa.deposit_register_n5 on
    samqa.deposit_register (
        orig_sys_ref,
        reconciled_flag
    );


-- sqlcl_snapshot {"hash":"460500bd2bddceea1cc951478210c30ec39600f9","type":"INDEX","name":"DEPOSIT_REGISTER_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEPOSIT_REGISTER_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEPOSIT_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ORIG_SYS_REF</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>RECONCILED_FLAG</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}