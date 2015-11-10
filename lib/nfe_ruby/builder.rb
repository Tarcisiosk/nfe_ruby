include ActionView::Helpers::NumberHelper

module NfeRuby
  class Builder
    @nfe_doc = nil

    def initialize(nfe_doc)
      @nfe_doc = nfe_doc
    end
    
    #number_to_currency(totalbc, separator: ",", delimiter: "", format: "%n")
    # Montar documento XML de uma NF-e (Nokogiri Builder)
    def to_builder
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.NFe(:xmlns => 'http://www.portalfiscal.inf.br/nfe') {
          xml.infNFe(:Id => "NFe#{@nfe_doc.chave_acesso}", :versao => '3.10') {
            xml.ide {
              xml.cUF @nfe_doc.ide.c_uf
              xml.cNF "%08d" % @nfe_doc.ide.c_nf
              xml.natOp @nfe_doc.ide.nat_op
              xml.indPag @nfe_doc.ide.ind_pag
              xml.mod @nfe_doc.ide.mod
              xml.serie @nfe_doc.ide.serie
              xml.nNF @nfe_doc.ide.n_nf
              xml.dhEmi NfeRuby::Util::formatar_dh(@nfe_doc.ide.dh_emi)
              xml.dhSaiEnt NfeRuby::Util::formatar_dh(@nfe_doc.ide.dh_sai_ent)
              xml.tpNF @nfe_doc.ide.tp_nf
              xml.idDest @nfe_doc.ide.id_dest
              xml.cMunFG @nfe_doc.ide.c_mun_fg
              xml.tpImp @nfe_doc.ide.tp_imp
              xml.tpEmis @nfe_doc.ide.tp_emis
              xml.cDV @nfe_doc.ide.c_dv
              xml.tpAmb @nfe_doc.ide.tp_amb
              xml.finNFe @nfe_doc.ide.fin_nfe
              xml.indFinal @nfe_doc.ide.ind_final
              xml.indPres @nfe_doc.ide.ind_pres
              xml.procEmi @nfe_doc.ide.proc_emi
              xml.verProc @nfe_doc.ide.ver_proc
            }
            xml.emit {
              xml.CNPJ @nfe_doc.emit.cnpj_cpf
              xml.xNome @nfe_doc.emit.x_nome
              xml.xFant @nfe_doc.emit.x_fant
              xml.enderEmit {
                xml.xLgr @nfe_doc.emit.ender_emit.x_lgr
                xml.nro @nfe_doc.emit.ender_emit.nro
                xml.xCpl @nfe_doc.emit.ender_emit.x_cpl
                xml.xBairro @nfe_doc.emit.ender_emit.x_bairro
                xml.cMun @nfe_doc.emit.ender_emit.c_mun
                xml.xMun @nfe_doc.emit.ender_emit.x_mun
                xml.UF @nfe_doc.emit.ender_emit.uf
                xml.CEP @nfe_doc.emit.ender_emit.cep
                xml.cPais @nfe_doc.emit.ender_emit.c_pais
                xml.xPais @nfe_doc.emit.ender_emit.x_pais
                xml.fone @nfe_doc.emit.ender_emit.fone
              }
              xml.IE @nfe_doc.emit.ie
              xml.IM @nfe_doc.emit.im if @nfe_doc.emit.im.present?
              xml.CNAE @nfe_doc.emit.cnae
              xml.CRT @nfe_doc.emit.crt
            }
            xml.dest {
              xml.CNPJ @nfe_doc.dest.cnpj_cpf
              xml.xNome @nfe_doc.dest.x_nome
              xml.enderDest {
                xml.xLgr @nfe_doc.dest.ender_dest.x_lgr
                xml.nro @nfe_doc.dest.ender_dest.nro
                xml.xBairro @nfe_doc.dest.ender_dest.x_bairro
                xml.cMun @nfe_doc.dest.ender_dest.c_mun
                xml.xMun @nfe_doc.dest.ender_dest.x_mun
                xml.UF @nfe_doc.dest.ender_dest.uf
                xml.CEP @nfe_doc.dest.ender_dest.cep
                xml.cPais @nfe_doc.dest.ender_dest.c_pais
                xml.xPais @nfe_doc.dest.ender_dest.x_pais
                xml.fone @nfe_doc.dest.ender_dest.fone if @nfe_doc.dest.ender_dest.fone.present?
              }
              xml.indIEDest @nfe_doc.dest.ind_ie_dest
              xml.email @nfe_doc.dest.email if @nfe_doc.dest.email.present?
            }

            # Preencher tag de cada detalhe/item
            @nfe_doc.detalhes.each do |item|
              xml.det(:nItem => item.prod.n_item) {
                xml.prod {
                  xml.cProd item.prod.c_prod
                  xml.cEAN item.prod.c_ean
                  xml.xProd item.prod.x_prod
                  xml.NCM item.prod.ncm
                  xml.CFOP item.prod.cfop
                  xml.uCom item.prod.u_com
                  xml.qCom item.prod.q_com
                  xml.vUnCom number_to_currency(item.prod.v_un_com, separator: ".", delimiter: "", format: "%n")
                  xml.vProd number_to_currency(item.prod.v_prod, separator: ".", delimiter: "", format: "%n")
                  xml.cEANTrib item.prod.c_ean_trib
                  xml.uTrib item.prod.u_trib
                  xml.qTrib item.prod.q_trib
                  xml.vUnTrib number_to_currency(item.prod.v_un_trib, separator: ".", delimiter: "", format: "%n")
                  xml.indTot item.prod.ind_tot
                }
                xml.imposto {
                  xml.ICMS {
                    tag_icms = @nfe_doc.emit.crt.between?(1, 2) ? "ICMSSN#{item.imposto.icms.cst}" : "ICMS#{item.imposto.icms.cst}"
                    xml.send(tag_icms) {
                      xml.orig item.imposto.icms.orig
                      xml.CST item.imposto.icms.cst
                      xml.modBC item.imposto.icms.mod_bc if item.imposto.icms.mod_bc.present?
                      xml.vBC number_to_currency(item.imposto.icms.v_bc, separator: ".", delimiter: "", format: "%n") if item.imposto.icms.v_bc.present?
                      xml.pRedBC item.imposto.icms.p_red_bc if item.imposto.icms.p_red_bc.present?
                      xml.pICMS item.imposto.icms.p_icms if item.imposto.icms.p_icms.present?
                      xml.pDif item.imposto.icms.p_dif if item.imposto.icms.p_dif.present?
                      xml.vICMSDif  number_to_currency(item.imposto.icms.v_icms_dif, separator: ".", delimiter: "", format: "%n") if item.imposto.icms.v_icms_dif.present?
                      xml.vICMS number_to_currency(item.imposto.icms.v_icms, separator: ".", delimiter: "", format: "%n") if item.imposto.icms.v_icms
                      xml.modBCST item.imposto.icms.mod_bc_st if item.imposto.icms.mod_bc_st.present?
                      xml.pMVAST item.imposto.icms.p_mva_st if item.imposto.icms.p_mva_st.present?
                      xml.pRedBCST item.imposto.icms.p_red_bc_st if item.imposto.icms.p_red_bc_st.present?
                      xml.vBCST number_to_currency(item.imposto.icms.v_bc_st, separator: ".", delimiter: "", format: "%n") if item.imposto.icms.v_bc_st.present?
                      xml.pICMSST item.imposto.icms.p_icms_st if item.imposto.icms.p_icms_st.present?
                      xml.vICMSST number_to_currency(item.imposto.icms.v_icms_st, separator: ".", delimiter: "", format: "%n") if item.imposto.icms.v_icms_st.present?
                      xml.vICMSDeson number_to_currency(item.imposto.icms.v_icms_deson, separator: ".", delimiter: "", format: "%n") if item.imposto.icms.v_icms_deson.present?
                      xml.motDesICMS item.imposto.icms.mot_des_icms if item.imposto.icms.mot_des_icms.present?

 
                    }
                  }
                  if item.imposto.pis.cst.present?
                  xml.PIS {
                    tag_pis = case item.imposto.pis.cst
                                when '01'..'02' then 'PISAliq'
                                when '03' then 'PISQtde'
                                when '04'..'09' then 'PISNT'
                                when '99' then 'PISOutr'
                              end
                    xml.send(tag_pis) {
                      xml.CST item.imposto.pis.cst if item.imposto.pis.cst.present?
                    }
                  }
                  end
                  if item.imposto.cofins.cst.present?
                    xml.COFINS {
                      tag_cofins = case item.imposto.cofins.cst
                                     when '01'..'02' then 'COFINSAliq'
                                     when '03' then 'COFINSQtde'
                                     when '04'..'09' then 'COFINSNT'
                                     when '99' then 'COFINSOutr'
                                   end
                      xml.send(tag_cofins) {
                        xml.CST item.imposto.cofins.cst if item.imposto.cofins.cst.present?
                      }
                    }
                  end
                }
              }
            end
            xml.total {
              xml.ICMSTot {
                xml.vBC  number_to_currency(@nfe_doc.total.icms.v_bc, separator: ".", delimiter: "", format: "%n")
                xml.vICMS number_to_currency(@nfe_doc.total.icms.v_icms, separator: ".", delimiter: "", format: "%n")
                xml.vICMSDeson number_to_currency(@nfe_doc.total.icms.v_icms_deson, separator: "", delimiter: "", format: "%n") if @nfe_doc.total.icms.v_icms_deson.present?
                xml.vBCST  number_to_currency(@nfe_doc.total.icms.v_bc_st, separator: ".", delimiter: "", format: "%n")
                xml.vST  number_to_currency(@nfe_doc.total.icms.v_st, separator: ".", delimiter: "", format: "%n")
                xml.vProd  number_to_currency(@nfe_doc.total.icms.v_prod, separator: ".", delimiter: "", format: "%n")
                xml.vFrete  number_to_currency(@nfe_doc.total.icms.v_frete, separator: ".", delimiter: "", format: "%n") if @nfe_doc.total.icms.v_frete.present?
                xml.vSeg  number_to_currency(@nfe_doc.total.icms.v_seg, separator: ".", delimiter: "", format: "%n") if @nfe_doc.total.icms.v_seg.present?
                xml.vDesc number_to_currency( @nfe_doc.total.icms.v_desc, separator: ".", delimiter: "", format: "%n") if @nfe_doc.total.icms.v_desc.present?
                xml.vII  number_to_currency(@nfe_doc.total.icms.v_ii, separator: ".", delimiter: "", format: "%n")
                xml.vIPI number_to_currency(@nfe_doc.total.icms.v_ipi, separator: ".", delimiter: "", format: "%n")
                xml.vPIS  number_to_currency(@nfe_doc.total.icms.v_pis, separator: ".", delimiter: "", format: "%n")
                xml.vCOFINS  number_to_currency(@nfe_doc.total.icms.v_cofins, separator: ".", delimiter: "", format: "%n")
                xml.vOutro  number_to_currency(@nfe_doc.total.icms.v_outro, separator: ".", delimiter: "", format: "%n") if @nfe_doc.total.icms.v_outro.present?
                xml.vNF  number_to_currency(@nfe_doc.total.icms.v_nf, separator: ".", delimiter: "", format: "%n")
              }
            }
            xml.transp {
              xml.modFrete @nfe_doc.transp.mod_frete
            }
          }
        }
      end
    end
  end
end
