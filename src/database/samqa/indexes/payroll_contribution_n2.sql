create index samqa.payroll_contribution_n2 on
    samqa.payroll_contribution (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"062703de905bf0b4943698da593c72bb91ea0c88","type":"INDEX","name":"PAYROLL_CONTRIBUTION_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAYROLL_CONTRIBUTION_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAYROLL_CONTRIBUTION</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}