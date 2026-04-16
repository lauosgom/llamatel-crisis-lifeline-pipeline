import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from google.cloud import bigquery
from google.oauth2 import service_account

st.set_page_config(
    page_title="Llamadas Teléfono de la Esperanza",
    layout="wide"
)

st.markdown("""
    <style>
    .block-container { padding-top: 2rem; }
    h1 { color: #085041; font-weight: 500; }
    </style>
""", unsafe_allow_html=True)

TEAL = ["#E1F5EE","#9FE1CB","#5DCAA5","#1D9E75","#0F6E56","#085041","#04342C","#02211C"]

@st.cache_data(ttl=3600)
def load_data():
    credentials = service_account.Credentials.from_service_account_info(
        st.secrets["gcp_service_account"],
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    client = bigquery.Client(credentials=credentials, project="singular-arbor-401018")
    query = """
        SELECT
            llamada_datetime,
            llamante_sexo,
            llamante_edad,
            llamante_problematica_1
        FROM `singular-arbor-401018.marts.dashboard_calls`
        WHERE llamada_datetime IS NOT NULL
    """
    df = client.query(query).to_dataframe()
    df["llamada_datetime"] = pd.to_datetime(df["llamada_datetime"])
    df["year"] = df["llamada_datetime"].dt.year
    df["month_num"] = df["llamada_datetime"].dt.month
    df["month"] = df["llamada_datetime"].dt.strftime("%b")
    return df

df = load_data()

st.title("Llamadas Teléfono de la Esperanza")

years = sorted(df["year"].unique(), reverse=True)
selected_years = st.multiselect(
    "Seleccionar años",
    options=years,
    default=[max(years)]
)

if not selected_years:
    st.warning("Por favor selecciona al menos un año.")
    st.stop()

df_filtered = df[df["year"].isin(selected_years)]

prev_years = [y - 1 for y in selected_years]
df_prev = df[df["year"].isin(prev_years)]

if len(selected_years) == 1:
    current_year = selected_years[0]
    prev_year = current_year - 1
    max_month = df_filtered["month_num"].max()
    df_prev_comparable = df_prev[df_prev["month_num"] <= max_month]
else:
    df_prev_comparable = df_prev

total = len(df_filtered)
total_prev = len(df_prev_comparable)

if total_prev > 0:
    delta_pct = (total - total_prev) / total_prev * 100
    delta_str = f"{delta_pct:+.1f}% vs mismo periodo año anterior"
else:
    delta_str = None

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric("Personas escuchadas", f"{total:,}", delta=delta_str)

with col2:
    if "llamante_sexo" in df_filtered.columns:
        mujer = len(df_filtered[df_filtered["llamante_sexo"].str.lower().str.contains("mujer|femen|f", na=False)])
        st.metric("Mujeres", f"{mujer:,}", delta=f"{mujer/total*100:.1f}% del total" if total > 0 else None)

with col3:
    if "llamante_edad" in df_filtered.columns:
        try:
            avg_age = pd.to_numeric(df_filtered["llamante_edad"], errors="coerce").mean()
            st.metric("Edad media", f"{avg_age:.1f} años")
        except:
            st.metric("Edad media", "N/A")

with col4:
    if "llamante_problematica_1" in df_filtered.columns:
        top_problem = df_filtered["llamante_problematica_1"].dropna().mode()
        if len(top_problem) > 0:
            st.metric("Problema más frecuente", top_problem[0][:30])

st.markdown("---")

col_left, col_right = st.columns([2, 1])

with col_left:
    st.subheader("Número de llamadas por mes")
    monthly = (
        df_filtered
        .groupby(["month_num", "month", "year"])
        .size()
        .reset_index(name="llamadas")
        .sort_values("month_num")
    )
    month_order = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    fig_bar = px.bar(
        monthly,
        x="month",
        y="llamadas",
        color="year",
        color_discrete_sequence=TEAL,
        category_orders={"month": month_order},
        labels={"llamadas": "Llamadas", "month": "Mes", "year": "Año"}
    )
    fig_bar.update_layout(
        plot_bgcolor="#F5F3EE",
        paper_bgcolor="rgba(0,0,0,0)",
        legend_title="Año",
        margin=dict(t=20, b=20),
        font=dict(color="#085041")
    )
    st.plotly_chart(fig_bar, use_container_width=True)

with col_right:
    st.subheader("Género")
    if "llamante_sexo" in df_filtered.columns:
        gender_counts = df_filtered["llamante_sexo"].value_counts().reset_index()
        gender_counts.columns = ["sexo", "count"]
        fig_gender = px.pie(
            gender_counts,
            names="sexo",
            values="count",
            hole=0.5,
            color_discrete_sequence=["#1D9E75", "#085041", "#5DCAA5"]
        )
        fig_gender.update_traces(textposition="inside", textinfo="percent")
        fig_gender.update_layout(
            paper_bgcolor="rgba(0,0,0,0)",
            margin=dict(t=20, b=20),
            legend=dict(orientation="h", yanchor="bottom", y=-0.2),
            font=dict(color="#085041")
        )
        st.plotly_chart(fig_gender, use_container_width=True)

col_bottom_left, col_bottom_right = st.columns(2)

with col_bottom_left:
    st.subheader("Top 10 problemáticas")
    if "llamante_problematica_1" in df_filtered.columns:
        problems = (
            df_filtered["llamante_problematica_1"]
            .dropna()
            .value_counts()
            .head(10)
            .reset_index()
        )
        problems.columns = ["problematica", "count"]
        problems = problems.sort_values("count", ascending=True)
        fig_prob = px.bar(
            problems,
            x="count",
            y="problematica",
            orientation="h",
            color_discrete_sequence=["#1D9E75"],
            labels={"count": "Llamadas", "problematica": ""}
        )
        fig_prob.update_layout(
            plot_bgcolor="#F5F3EE",
            paper_bgcolor="rgba(0,0,0,0)",
            margin=dict(t=20, b=20),
            font=dict(color="#085041")
        )
        st.plotly_chart(fig_prob, use_container_width=True)

with col_bottom_right:
    st.subheader("Distribución por edad")
    if "llamante_edad" in df_filtered.columns:
        edad_series = pd.to_numeric(df_filtered["llamante_edad"], errors="coerce").dropna()
        if len(edad_series) > 0:
            fig_age = px.histogram(
                edad_series,
                nbins=20,
                color_discrete_sequence=["#1D9E75"],
                labels={"value": "Edad", "count": "Llamadas"}
            )
            fig_age.update_layout(
                plot_bgcolor="#F5F3EE",
                paper_bgcolor="rgba(0,0,0,0)",
                margin=dict(t=20, b=20),
                showlegend=False,
                font=dict(color="#085041")
            )
            st.plotly_chart(fig_age, use_container_width=True)
        else:
            edad_counts = df_filtered["llamante_edad"].value_counts().head(15).reset_index()
            edad_counts.columns = ["edad", "count"]
            fig_age = px.bar(
                edad_counts,
                x="edad",
                y="count",
                color_discrete_sequence=["#1D9E75"],
                labels={"count": "Llamadas", "edad": "Edad"}
            )
            fig_age.update_layout(
                plot_bgcolor="#F5F3EE",
                paper_bgcolor="rgba(0,0,0,0)",
                margin=dict(t=20, b=20),
                font=dict(color="#085041")
            )
            st.plotly_chart(fig_age, use_container_width=True)

st.markdown("---")
st.caption("Datos anonimizados · Teléfono de la Esperanza · Actualizado cada hora")