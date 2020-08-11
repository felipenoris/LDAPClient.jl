
#LBER_F( void )
#ber_free LDAP_P((
#    BerElement *ber,
#    int freebuf ));
function ber_free(ber_element_handle::Ptr{Cvoid}, freebuf::Integer)
    ccall((:ber_free, liblber), Cvoid, (Ptr{Cvoid}, Cint), ber_element_handle, freebuf)
end
