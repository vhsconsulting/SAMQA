create index samqa.i_acn_employer_migration on
    samqa.acn_employer_migration (
        batch_number
    );


-- sqlcl_snapshot {"hash":"4509e1b13ebdc2990c7a3a42f7401c158e6cc1e4","type":"INDEX","name":"I_ACN_EMPLOYER_MIGRATION","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>I_ACN_EMPLOYER_MIGRATION</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACN_EMPLOYER_MIGRATION</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}