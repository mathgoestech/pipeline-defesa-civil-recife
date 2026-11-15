"""Padronização de ocorrencia/solicitacao e construção da dim_solicitacao (ETL).
Mantido fora do notebook para o ETL.ipynb ter só células de chamada (menos conflito de merge)."""
import pandas as pd

SEM_OCORRENCIA = "Sem ocorrência registrada"
SEM_SOLICITACAO = "Não informada"


def gerar_chave(serie):
    return (
        serie.str.lower()
        .str.replace(r"[^ -~]", "", regex=True)
        .str.replace(r"\s+", " ", regex=True)
        .str.strip()
    )


def padronizar_solicitacao_ocorrencia(df, mapa):
    df = df.copy()
    resultado = {}
    for tipo in ("ocorrencia", "solicitacao"):
        m = mapa[mapa["tipo"] == tipo].set_index("chave")
        chave = gerar_chave(df[tipo])
        nao_mapeadas = sorted(set(chave.dropna()) - set(m.index))
        assert not nao_mapeadas, f"{tipo}: valores sem mapeamento: {nao_mapeadas}"
        resultado[tipo] = (chave.map(m["valor_padrao"]), chave.map(m["grupo"]))

    df["ocorrencia_padrao"] = resultado["ocorrencia"][0].fillna(SEM_OCORRENCIA)
    df["solicitacao_padrao"] = resultado["solicitacao"][0].fillna(SEM_SOLICITACAO)
    df["grupo_solicitacao"] = resultado["solicitacao"][1].replace("", pd.NA).fillna(SEM_SOLICITACAO)
    return df


def construir_dim_solicitacao(df):
    dim = (
        df[["ocorrencia_padrao", "solicitacao_padrao", "grupo_solicitacao"]]
        .drop_duplicates()
        .sort_values(["ocorrencia_padrao", "solicitacao_padrao"])
        .reset_index(drop=True)
    )
    desconhecido = (dim["ocorrencia_padrao"] == SEM_OCORRENCIA) & (dim["solicitacao_padrao"] == SEM_SOLICITACAO)
    dim = pd.concat([dim[desconhecido], dim[~desconhecido]], ignore_index=True)
    dim.insert(0, "id_solicitacao", range(len(dim)))
    return dim.rename(columns={"ocorrencia_padrao": "ocorrencia", "solicitacao_padrao": "solicitacao"})