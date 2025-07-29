create or replace package samqa.ora73pkg is
    procedure open_file (
        filename_in in varchar2
    );

    procedure close_file;

    procedure pl (
        line_in in varchar2
    );

end ora73pkg;
/


-- sqlcl_snapshot {"hash":"130a92074777ff2be1b588a866eb65cf51eaf6dc","type":"PACKAGE_SPEC","name":"ORA73PKG","schemaName":"SAMQA","sxml":""}