% Skrypt do analizy i wizualizacji danych meteorologicznych

%% ========================== 1. Wczytanie danych ==========================
% Definiuje nazwę pliku wejściowego CSV.
dane_plik = 'dane-meteo1.csv';

% Wczytuje dane z pliku CSV z separatorem w postaci przecinka.
dane = dlmread(dane_plik, ',');

% Przypisuje poszczególne kolumny macierzy 'dane' do odpowiednich zmiennych.
godzina = dane(:, 1);       % Kolumna 1: Godzina obserwacji (0-23)
temperatura = dane(:, 2);   % Kolumna 2: Temperatura [°C]
opady = dane(:, 3);         % Kolumna 3: Opady [mm]
wiatr = dane(:, 4);         % Kolumna 4: Prędkość wiatru [km/h]

%% ====================== 2. Podstawowe statystyki =======================
% Oblicza średnią, maksymalną i minimalną wartość temperatury z całego okresu.
srednia_temperatura = mean(temperatura);
maksymalna_temperatura = max(temperatura);
minimalna_temperatura = min(temperatura);

% Oblicza całkowitą sumę opadów z całego okresu.
suma_opady = sum(opady);

% Oblicza średnią prędkość wiatru z całego okresu.
srednia_wiatr = mean(wiatr);

% Wyświetla obliczone podstawowe statystyki w formie tabeli w konsoli.
fprintf('\n2. Podstawowe statystyki:\n');
fprintf('--------------------------------------\n');
fprintf('Statystyka              | Wartość\n');
fprintf('--------------------------------------\n');
fprintf('Średnia temperatura     | %.2f °C\n', srednia_temperatura);
fprintf('Maksymalna temperatura  | %.2f °C\n', maksymalna_temperatura);
fprintf('Minimalna temperatura   | %.2f °C\n', minimalna_temperatura);
fprintf('Suma opadów             | %.2f mm\n', suma_opady);
fprintf('Średnia prędkość wiatru | %.2f km/h\n', srednia_wiatr);
fprintf('--------------------------------------\n');

%% =============== 3. Analiza obserwacji z opadami ===============
% Znajduje indeksy obserwacji, w których wystąpiły opady (wartość > 0).
godziny_z_opadami = find(opady > 0);

% Oblicza procentowy udział godzin z opadami w stosunku do wszystkich obserwacji.
procent_godzin_z_opadami = 100 * length(godziny_z_opadami) / length(opady);

% Wyświetla liczbę i procent obserwacji z opadami.
fprintf('\n3. Filtrowanie danych z opadami:\n');
fprintf('--------------------------------------------------\n');
fprintf('Opis                         | Wartość\n');
fprintf('--------------------------------------------------\n');
fprintf('Liczba obserwacji z opadami  | %d\n', length(godziny_z_opadami));
fprintf('Procent obserwacji z opadami | %.1f%%\n', procent_godzin_z_opadami);
fprintf('--------------------------------------------------\n');

%% ============= 4. Średnia prędkość wiatru godzinowo ==============
% Inicjalizuje tablice do przechowywania sumy prędkości wiatru i liczby obserwacji dla każdej godziny (0-23).
suma_wiatru_godziny = zeros(24, 1);
liczba_wystepowania_godzin = zeros(24, 1);

% Iteruje przez wszystkie obserwacje, sumując prędkość wiatru i zliczając obserwacje dla każdej godziny.
for i = 1:length(godzina)
    g = godzina(i) + 1; % Indeks odpowiadający godzinie (0 -> 1, 1 -> 2, ..., 23 -> 24)
    suma_wiatru_godziny(g) = suma_wiatru_godziny(g) + wiatr(i);
    liczba_wystepowania_godzin(g) = liczba_wystepowania_godzin(g) + 1;
end

% Inicjalizuje tablicę na średnie prędkości wiatru dla każdej godziny.
srednia_wiatru_godziny = zeros(24, 1);

% Oblicza średnią prędkość wiatru dla każdej godziny, dzieląc sumę przez liczbę obserwacji.
for g = 1:24
    % Sprawdza, czy dla danej godziny były obserwacje, aby uniknąć dzielenia przez zero.
    if liczba_wystepowania_godzin(g) > 0
        srednia_wiatru_godziny(g) = suma_wiatru_godziny(g) / liczba_wystepowania_godzin(g);
    else
        srednia_wiatru_godziny(g) = 0; % Lub NaN, jeśli preferowane
    end
end

% Znajduje maksymalną średnią prędkość wiatru i godzinę jej wystąpienia.
[max_srednia_wiatru, max_wiatr_godzina_idx] = max(srednia_wiatru_godziny);
max_wiatr_godzina = max_wiatr_godzina_idx - 1; % Przeliczenie indeksu na godzinę (0-23)

% Wyświetla średnie prędkości wiatru dla każdej godziny oraz godzinę z najwyższą średnią.
fprintf('\n4. Średnia prędkość wiatru w poszczególnych godzinach:\n');
fprintf('---------------------------\n');
fprintf('Godzina | Średnia prędkość\n');
fprintf('---------------------------\n');
for g = 1:24
    fprintf('%7d | %.2f km/h\n', g - 1, srednia_wiatru_godziny(g));
end
fprintf('---------------------------\n');
fprintf('\nGodzina z najsilniejszym średnim wiatrem: Godzina %d, Średnia prędkość: %.2f km/h\n', max_wiatr_godzina, max_srednia_wiatru);

%% ============ 5. Analiza sum opadów i ciągów dni z opadami ============
% Określa liczbę wszystkich obserwacji i liczbę pełnych dni (zakładając 24 obserwacje na dzień).
liczba_obserwacji = length(opady);
liczba_dni = floor(liczba_obserwacji / 24); % Użycie floor dla pewności przy niepełnych danych

% Inicjalizuje tablicę na sumy opadów dla każdego dnia.
suma_opadow_dziennych = zeros(liczba_dni, 1);

% Wyświetla nagłówek tabeli sum opadów dziennych.
fprintf("\n5. Suma opadów dla poszczególnych dni:\n");
fprintf('------------------------------------------------------\n');
fprintf('Dzień | Suma opadów [mm] | Obserwacje z opadami [%%]\n');
fprintf('------------------------------------------------------\n');

% Iteruje przez każdy dzień, obliczając sumę opadów i procent obserwacji z opadami.
for dzien = 1:liczba_dni
    % Wyznacza indeksy obserwacji dla bieżącego dnia.
    indeksy_dnia = (dzien - 1) * 24 + 1 : dzien * 24;

    % Wyodrębnia dane o opadach dla bieżącego dnia.
    opady_dnia = opady(indeksy_dnia);

    % Oblicza sumę opadów w danym dniu.
    suma_opadow_dziennych(dzien) = sum(opady_dnia);

    % Zlicza liczbę obserwacji z opadami (> 0) w danym dniu.
    liczba_opadow_dzien = sum(opady_dnia > 0);

    % Oblicza procent obserwacji z opadami w danym dniu.
    if liczba_opadow_dzien > 0
        procent_opadow_dzien = (liczba_opadow_dzien / 24) * 100;
    else
        procent_opadow_dzien = 0.00;
    end

    % Wyświetla wyniki dla bieżącego dnia.
    fprintf('%5d | %16.2f | %22.2f%%\n', dzien, suma_opadow_dziennych(dzien), procent_opadow_dzien);
end
fprintf('------------------------------------------------------\n');

% --- Analiza najdłuższych ciągów dni z opadami ---
% Tworzy wektory logiczne wskazujące dni z jakimikolwiek opadami (>0) i opadami znaczącymi (>1mm).
dni_z_opadami = suma_opadow_dziennych > 0;
dni_z_opadami_znaczacymi = suma_opadow_dziennych > 1;

% Inicjalizuje zmienne do śledzenia najdłuższych ciągów dni z opadami.
max_okres_z_opadami = 0;
biezacy_okres_z_opadami = 0;
poczatek_max_okresu_z_opadami = 0; % Dzień rozpoczęcia najdłuższego ciągu

max_okres_z_opadami_znaczacymi = 0;
biezacy_okres_z_opadami_znaczacymi = 0;
poczatek_max_okresu_z_opadami_znaczacymi = 0; % Dzień rozpoczęcia najdłuższego ciągu znaczących opadów

% Iteruje przez dni, aby znaleźć najdłuższe ciągi opadów.
for dzien = 1:liczba_dni
    % Sprawdza ciągłość dni z jakimikolwiek opadami.
    if dni_z_opadami(dzien)
        biezacy_okres_z_opadami = biezacy_okres_z_opadami + 1;
        % Aktualizuje najdłuższy okres, jeśli bieżący jest dłuższy.
        if biezacy_okres_z_opadami > max_okres_z_opadami
            max_okres_z_opadami = biezacy_okres_z_opadami;
            poczatek_max_okresu_z_opadami = dzien - biezacy_okres_z_opadami + 1;
        end
    else
        % Resetuje licznik bieżącego okresu, jeśli dzień był bez opadów.
        biezacy_okres_z_opadami = 0;
    end

    % Sprawdza ciągłość dni ze znaczącymi opadami (> 1 mm).
    if dni_z_opadami_znaczacymi(dzien)
        biezacy_okres_z_opadami_znaczacymi = biezacy_okres_z_opadami_znaczacymi + 1;
        % Aktualizuje najdłuższy okres znaczących opadów.
        if biezacy_okres_z_opadami_znaczacymi > max_okres_z_opadami_znaczacymi
            max_okres_z_opadami_znaczacymi = biezacy_okres_z_opadami_znaczacymi;
            poczatek_max_okresu_z_opadami_znaczacymi = dzien - biezacy_okres_z_opadami_znaczacymi + 1;
        end
    else
        % Resetuje licznik bieżącego okresu znaczących opadów.
        biezacy_okres_z_opadami_znaczacymi = 0;
    end
end

% Oblicza dzień końcowy dla każdego najdłuższego okresu.
koniec_max_okresu_z_opadami = poczatek_max_okresu_z_opadami + max_okres_z_opadami - 1;
koniec_max_okresu_z_opadami_znaczacymi = poczatek_max_okresu_z_opadami_znaczacymi + max_okres_z_opadami_znaczacymi - 1;

% Wyświetla wyniki analizy najdłuższych okresów opadów.
fprintf("\nAnaliza najdłuższych okresów opadów:\n");
fprintf("-------------------------------------------------------------\n");
fprintf("%-28s | %-14s | %-10s | %-6s\n", "Rodzaj opadów", "Długość okresu", "Początek", "Koniec");
fprintf("-------------------------------------------------------------\n");
fprintf("%-27s | %10d dni | %9d | %5d\n",
        "Jakiekolwiek opady (>0 mm)", max_okres_z_opadami, poczatek_max_okresu_z_opadami, koniec_max_okresu_z_opadami);
fprintf("%-27s | %10d dni | %9d | %5d\n",
        "Opad > 1 mm", max_okres_z_opadami_znaczacymi, poczatek_max_okresu_z_opadami_znaczacymi, koniec_max_okresu_z_opadami_znaczacymi);
fprintf("-------------------------------------------------------------\n");

%% ======= 6. Prawdopodobieństwo opadów o danej godzinie ==========
% Inicjalizuje licznik dni z opadami dla każdej godziny.
liczba_dni_z_opadami_o_godzinie = zeros(24, 1);

% Iteruje przez wszystkie obserwacje, zliczając dni, w których wystąpiły opady o danej godzinie.
% Używa pomocniczej macierzy, aby uniknąć wielokrotnego liczenia tego samego dnia.
czy_dzien_liczyl_opad = zeros(liczba_dni, 24); % Macierz [dzień, godzina]

for i = 1:liczba_obserwacji
    aktualna_godzina_idx = godzina(i) + 1; % Indeks godziny (1-24)
    aktualny_dzien = floor((i-1) / 24) + 1; % Numer dnia (1-liczba_dni)

    % Sprawdza, czy wystąpiły opady i czy ten dzień/godzina nie był już liczony.
    if opady(i) > 0 && aktualny_dzien <= liczba_dni && czy_dzien_liczyl_opad(aktualny_dzien, aktualna_godzina_idx) == 0
        liczba_dni_z_opadami_o_godzinie(aktualna_godzina_idx) = liczba_dni_z_opadami_o_godzinie(aktualna_godzina_idx) + 1;
        czy_dzien_liczyl_opad(aktualny_dzien, aktualna_godzina_idx) = 1; % Oznacza dzień/godzinę jako policzony
    end
end

% Oblicza prawdopodobieństwo wystąpienia opadów dla każdej godziny (liczba dni z opadem / całkowita liczba dni).
prawdopodobienstwo_opadow_godzinowe = liczba_dni_z_opadami_o_godzinie / liczba_dni;

% Wyświetla wyniki prawdopodobieństwa opadów godzinowych.
fprintf("\n6. Prawdopodobieństwo wystąpienia opadów o danej godzinie:\n");
fprintf("----------------------------------------------------\n");
fprintf("Godzina | Liczba dni z opadami | Prawdopodobieństwo\n");
fprintf("----------------------------------------------------\n");
for godz_idx = 1:24
    fprintf("%7d | %20d | %15.4f\n",
            godz_idx - 1, liczba_dni_z_opadami_o_godzinie(godz_idx), prawdopodobienstwo_opadow_godzinowe(godz_idx));
end
fprintf("----------------------------------------------------\n");


%% ============ 7. Analiza współwystępowania opadów i wiatru ============
% Tworzy wektory logiczne dla różnych warunków pogodowych.
bez_opadow = opady == 0; % True dla obserwacji bez opadów
bez_wiatru = wiatr == 0; % True dla obserwacji bez wiatru
z_opadami = opady > 0;   % True dla obserwacji z opadami
z_wiatrem = wiatr > 0;   % True dla obserwacji z wiatrem

% Zlicza liczbę obserwacji dla każdej kombinacji warunków opadów i wiatru.
liczba_bez_opadow_bez_wiatru = sum(bez_opadow & bez_wiatru); % Przypadek a)
liczba_z_opadami_bez_wiatru = sum(z_opadami & bez_wiatru);   % Przypadek b)
liczba_bez_opadow_z_wiatrem = sum(bez_opadow & z_wiatrem);   % Przypadek c)
liczba_z_opadami_z_wiatrem = sum(z_opadami & z_wiatrem);     % Przypadek d)

% Suma kontrolna - powinna być równa całkowitej liczbie obserwacji.
suma_kontrolna_obserwacji = liczba_bez_opadow_bez_wiatru + liczba_z_opadami_bez_wiatru + liczba_bez_opadow_z_wiatrem + liczba_z_opadami_z_wiatrem;

% Oblicza procentowy udział każdej kombinacji warunków.
procent_a = liczba_bez_opadow_bez_wiatru / liczba_obserwacji * 100;
procent_b = liczba_z_opadami_bez_wiatru / liczba_obserwacji * 100;
procent_c = liczba_bez_opadow_z_wiatrem / liczba_obserwacji * 100;
procent_d = liczba_z_opadami_z_wiatrem / liczba_obserwacji * 100;

% Wyświetla wyniki analizy współwystępowania opadów i wiatru.
fprintf("\n7. Analiza przypadków opadów i wiatru:\n");
fprintf("---------------------------------------------------------------------\n");
fprintf("Przypadek                      | Liczba obserwacji | Procent [%%]\n");
fprintf("---------------------------------------------------------------------\n");
fprintf("a) bez opadów i bez wiatru     | %17d | %10.2f\n", liczba_bez_opadow_bez_wiatru, procent_a);
fprintf("b) z opadami i bez wiatru      | %17d | %10.2f\n", liczba_z_opadami_bez_wiatru, procent_b);
fprintf("c) bez opadów, ale z wiatrem   | %17d | %10.2f\n", liczba_bez_opadow_z_wiatrem, procent_c);
fprintf("d) z opadami oraz wiatrem      | %17d | %10.2f\n", liczba_z_opadami_z_wiatrem, procent_d);
fprintf("---------------------------------------------------------------------\n");
fprintf("SUMA                           | %17d | %10.2f\n", suma_kontrolna_obserwacji, 100.0);

%% ============== 8. Analiza godzinowych przyrostów temperatury ==============
% Inicjalizuje wektor na godzinowe przyrosty temperatury. Rozmiar taki sam jak 'temperatura'.
przyrosty_temperatury = zeros(size(temperatura));
liczba_godzin_na_dzien = 24; % Stała definiująca liczbę godzin w dobie

% Iteruje przez każdy dzień, aby obliczyć przyrosty temperatury godzina do godziny.
for dzien = 1:liczba_dni
    % Wyznacza indeksy obserwacji dla bieżącego dnia.
    indeks_startowy_dnia = (dzien - 1) * liczba_godzin_na_dzien + 1;
    indeks_koncowy_dnia = dzien * liczba_godzin_na_dzien;

    % Oblicza przyrost dla pierwszej godziny dnia (względem ostatniej godziny poprzedniego dnia).
    if dzien > 1
        indeks_poprzedniej_godziny = indeks_startowy_dnia - 1;
        przyrosty_temperatury(indeks_startowy_dnia) = temperatura(indeks_startowy_dnia) - temperatura(indeks_poprzedniej_godziny);
    else
        % Dla pierwszej godziny pierwszego dnia przyrost jest nieokreślony (NaN).
        przyrosty_temperatury(indeks_startowy_dnia) = NaN;
    end

    % Oblicza przyrosty dla pozostałych godzin dnia (względem poprzedniej godziny tego samego dnia).
    for i = (indeks_startowy_dnia + 1) : indeks_koncowy_dnia
         % Upewnia się, że nie wyjdzie poza zakres danych (na wypadek niepełnych dni na końcu)
        if i > 1 && i <= length(temperatura)
            przyrosty_temperatury(i) = temperatura(i) - temperatura(i - 1);
        elseif i > length(temperatura)
             przyrosty_temperatury(i) = NaN; % Oznacza brak danych
        end
    end
end

% Inicjalizuje tablice na statystyki przyrostów dla każdej godziny (0-23).
srednie_przyrosty_godzinowe = zeros(liczba_godzin_na_dzien, 1);
odchylenia_std_przyrostow = zeros(liczba_godzin_na_dzien, 1);
min_przyrosty_godzinowe = zeros(liczba_godzin_na_dzien, 1);
max_przyrosty_godzinowe = zeros(liczba_godzin_na_dzien, 1);

% Iteruje przez każdą godzinę (0-23), aby obliczyć statystyki przyrostów.
for godz_idx = 1:liczba_godzin_na_dzien % godz_idx od 1 do 24
    % Zbiera wszystkie przyrosty zarejestrowane o danej godzinie (indeks godz_idx) ze wszystkich dni.
    indeksy_dla_godziny = godz_idx : liczba_godzin_na_dzien : length(przyrosty_temperatury);
    przyrosty_o_danej_godzinie = przyrosty_temperatury(indeksy_dla_godziny);

    % Usuwa wartości NaN (np. z pierwszej godziny pierwszego dnia).
    przyrosty_o_danej_godzinie = przyrosty_o_danej_godzinie(~isnan(przyrosty_o_danej_godzinie));

    % Oblicza statystyki, jeśli istnieją dane dla danej godziny.
    if ~isempty(przyrosty_o_danej_godzinie)
        srednie_przyrosty_godzinowe(godz_idx) = mean(przyrosty_o_danej_godzinie);
        odchylenia_std_przyrostow(godz_idx) = std(przyrosty_o_danej_godzinie);
        min_przyrosty_godzinowe(godz_idx) = min(przyrosty_o_danej_godzinie);
        max_przyrosty_godzinowe(godz_idx) = max(przyrosty_o_danej_godzinie);
    else
        % Ustawia NaN, jeśli brak danych dla danej godziny.
        srednie_przyrosty_godzinowe(godz_idx) = NaN;
        odchylenia_std_przyrostow(godz_idx) = NaN;
        min_przyrosty_godzinowe(godz_idx) = NaN;
        max_przyrosty_godzinowe(godz_idx) = NaN;
    end
end

% Wyświetla wyniki analizy godzinowych przyrostów temperatury.
fprintf("\n8. Analiza godzinowych przyrostów temperatury:\n");
fprintf("-------------------------------------------------------------------------------\n");
fprintf("Godzina | Średni przyrost | Odchylenie std. | Min. przyrost | Maks. przyrost\n");
fprintf("-------------------------------------------------------------------------------\n");
for godz_idx = 1:24
    fprintf("%7d | %15.2f | %15.2f | %13.2f | %14.2f\n",
            godz_idx - 1, srednie_przyrosty_godzinowe(godz_idx), odchylenia_std_przyrostow(godz_idx),
            min_przyrosty_godzinowe(godz_idx), max_przyrosty_godzinowe(godz_idx));
end
fprintf("-------------------------------------------------------------------------------\n");


%% ====================== 9. Wizualizacja danych =======================

% --- 9.1 Wykres 2D: Średnia temperatura w zależności od godziny ---
% Oblicza średnią temperaturę dla każdej godziny (ponownie, dla pewności i czytelności).
srednia_temperatura_godzinowa_plot = zeros(24, 1);
licznik_godzin_plot = zeros(24, 1);

for i = 1:length(temperatura)
    godzina_indeks = godzina(i) + 1; % Indeks 1-24
    if godzina_indeks >= 1 && godzina_indeks <= 24 % Dodatkowe zabezpieczenie
        srednia_temperatura_godzinowa_plot(godzina_indeks) = srednia_temperatura_godzinowa_plot(godzina_indeks) + temperatura(i);
        licznik_godzin_plot(godzina_indeks) = licznik_godzin_plot(godzina_indeks) + 1;
    end
end

% Unika dzielenia przez zero, jeśli dla jakiejś godziny nie ma danych.
srednia_temperatura_godzinowa_plot(licznik_godzin_plot > 0) = ...
    srednia_temperatura_godzinowa_plot(licznik_godzin_plot > 0) ./ licznik_godzin_plot(licznik_godzin_plot > 0);
srednia_temperatura_godzinowa_plot(licznik_godzin_plot == 0) = NaN; % Oznacza brak danych

% Tworzy nowe okno figury i rysuje wykres liniowy średniej temperatury od godziny.
figure; % Wykres 1
plot(0:23, srednia_temperatura_godzinowa_plot, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 5);
title('Średnia temperatura w zależności od godziny');
xlabel('Godzina');
ylabel('Średnia temperatura (°C)');
grid on; % Włącza siatkę
xticks(0:2:23); % Ustawia znaczniki osi X co 2 godziny
xlim([-0.5, 23.5]); % Ustawia zakres osi X

% --- 9.2 Histogram: Rozkład prędkości wiatru ---
% Tworzy nowe okno figury i rysuje histogram prędkości wiatru.
figure; % Wykres 2
hist(wiatr, 20); % Używa 20 przedziałów (można dostosować)
title('Rozkład częstotliwości prędkości wiatru');
xlabel('Prędkość wiatru (km/h)');
ylabel('Liczba obserwacji');
grid on;

% --- 9.3 Wykres Subplot: Średnia temperatura dzienna i suma opadów dziennych ---
% Oblicza średnią temperaturę i sumę opadów dla każdego dnia (ponownie, dla pewności).
srednia_temperatura_dzienna_plot = zeros(liczba_dni, 1);
suma_opadow_dziennych_plot = zeros(liczba_dni, 1);

for dzien = 1:liczba_dni
    indeksy_dnia = (dzien - 1) * 24 + 1 : dzien * 24;
    % Sprawdza, czy indeksy nie wychodzą poza zakres danych
    if max(indeksy_dnia) <= length(temperatura)
        srednia_temperatura_dzienna_plot(dzien) = mean(temperatura(indeksy_dnia));
        suma_opadow_dziennych_plot(dzien) = sum(opady(indeksy_dnia));
    else
        srednia_temperatura_dzienna_plot(dzien) = NaN; % Brak danych dla niepełnego dnia
        suma_opadow_dziennych_plot(dzien) = NaN;
    end
end

% Tworzy nowe okno figury dla subplotów.
figure; % Wykres 3

% Górny subplot: Średnia temperatura dzienna.
subplot(2, 1, 1); % 2 wiersze, 1 kolumna, pierwszy wykres
plot(1:liczba_dni, srednia_temperatura_dzienna_plot, 'r-', 'LineWidth', 1.5);
title('Średnia dobowa temperatura');
xlabel('Dzień');
ylabel('Temperatura (°C)');
grid on;
xlim([0.5, liczba_dni + 0.5]); % Dopasowuje zakres osi X

% Dolny subplot: Suma opadów dziennych.
subplot(2, 1, 2); % 2 wiersze, 1 kolumna, drugi wykres
bar(1:liczba_dni, suma_opadow_dziennych_plot, 'b'); % Wykres słupkowy dla opadów
title('Suma dobowa opadów');
xlabel('Dzień');
ylabel('Suma opadów (mm)');
grid on;
xlim([0.5, liczba_dni + 0.5]); % Dopasowuje zakres osi X

% --- 9.4 Wykres 3D: Zależność średnich godzinowych: temperatura, opady, wiatr ---
% Oblicza średnie wartości godzinowe dla temperatury, opadów i wiatru.
srednia_temp_godz_3d = zeros(24, 1);
srednie_opady_godz_3d = zeros(24, 1);
sredni_wiatr_godz_3d = zeros(24, 1);
licznik_godzin_3d = zeros(24, 1);

for i = 1:length(godzina)
    godzina_indeks = godzina(i) + 1; % Indeks 1-24
     if godzina_indeks >= 1 && godzina_indeks <= 24
        srednia_temp_godz_3d(godzina_indeks) = srednia_temp_godz_3d(godzina_indeks) + temperatura(i);
        srednie_opady_godz_3d(godzina_indeks) = srednie_opady_godz_3d(godzina_indeks) + opady(i);
        sredni_wiatr_godz_3d(godzina_indeks) = sredni_wiatr_godz_3d(godzina_indeks) + wiatr(i);
        licznik_godzin_3d(godzina_indeks) = licznik_godzin_3d(godzina_indeks) + 1;
     end
end

% Oblicza średnie, unikając dzielenia przez zero.
non_zero_indices = licznik_godzin_3d > 0;
srednia_temp_godz_3d(non_zero_indices) = srednia_temp_godz_3d(non_zero_indices) ./ licznik_godzin_3d(non_zero_indices);
srednie_opady_godz_3d(non_zero_indices) = srednie_opady_godz_3d(non_zero_indices) ./ licznik_godzin_3d(non_zero_indices);
sredni_wiatr_godz_3d(non_zero_indices) = sredni_wiatr_godz_3d(non_zero_indices) ./ licznik_godzin_3d(non_zero_indices);
% Ustawia NaN dla godzin bez danych
srednia_temp_godz_3d(~non_zero_indices) = NaN;
srednie_opady_godz_3d(~non_zero_indices) = NaN;
sredni_wiatr_godz_3d(~non_zero_indices) = NaN;

% Tworzy nowe okno figury i rysuje wykres punktowy 3D.
figure; % Wykres 4
scatter3(srednia_temp_godz_3d, srednie_opady_godz_3d, sredni_wiatr_godz_3d, 50, 0:23, 'filled'); % Kolor punktów zależny od godziny
title('Zależność średnich godzinowych: Temperatura, Opady, Wiatr');
xlabel('Średnia Temperatura (°C)');
ylabel('Średnie Opady (mm)');
zlabel('Średnia Prędkość Wiatru (km/h)');
grid on;
colorbar; % Dodaje pasek kolorów do interpretacji godziny
cbl = colorbar; % Uchwyt do paska kolorów
ylabel(cbl,'Godzina') % Etykieta paska kolorów

% Zmienia długość paska kolorów
pos_cbl = get(cbl, 'Position'); % Pobiera pozycję paska
skala_wysokosci = 0.8;
nowa_wysokosc = pos_cbl(4) * skala_wysokosci; % Ustawia nową wysokość jako ułamek oryginalnej wartości
przesuniecie_dol = (pos_cbl(4) - nowa_wysokosc) / 2; % Oblicza o ile trzeba przesunąć pasek
nowy_dol = pos_cbl(2) + przesuniecie_dol;
set(cbl, 'Position', [pos_cbl(1), nowy_dol, pos_cbl(3), nowa_wysokosc]); % Aktualizuje pozycję paska

%% ==================== 10. Zapis wyników do pliku =====================

% Definiuje nazwę pliku wyjściowego.
plik_wynikowy = 'wyniki_analizy.txt';

% Otwiera plik do zapisu (tryb 'w' - write, nadpisuje istniejący plik).
fid = fopen(plik_wynikowy, 'w');

% Sprawdza, czy plik został pomyślnie otwarty.
if fid == -1
    error('Błąd: Nie można otworzyć pliku do zapisu: %s', plik_wynikowy);
end

% --- Zapis sekcji 2: Podstawowe statystyki ---
fprintf(fid, '====================== 2. Podstawowe statystyki =======================\n\n');
fprintf(fid, '--------------------------------------\n');
fprintf(fid, 'Statystyka              | Wartość\n');
fprintf(fid, '--------------------------------------\n');
fprintf(fid, 'Średnia temperatura     | %.2f °C\n', srednia_temperatura);
fprintf(fid, 'Maksymalna temperatura  | %.2f °C\n', maksymalna_temperatura);
fprintf(fid, 'Minimalna temperatura   | %.2f °C\n', minimalna_temperatura);
fprintf(fid, 'Suma opadów             | %.2f mm\n', suma_opady);
fprintf(fid, 'Średnia prędkość wiatru | %.2f km/h\n', srednia_wiatr);
fprintf(fid, '--------------------------------------\n\n\n');

% --- Zapis sekcji 3: Analiza obserwacji z opadami ---
fprintf(fid, '=============== 3. Analiza obserwacji z opadami ===============\n\n');
fprintf(fid, '--------------------------------------------------\n');
fprintf(fid, 'Opis                         | Wartość\n');
fprintf(fid, '--------------------------------------------------\n');
fprintf(fid, 'Liczba obserwacji z opadami  | %d\n', length(godziny_z_opadami));
fprintf(fid, 'Procent obserwacji z opadami | %.1f%%\n', procent_godzin_z_opadami);
fprintf(fid, '--------------------------------------------------\n\n\n');

% --- Zapis sekcji 4: Średnia prędkość wiatru godzinowo ---
fprintf(fid, '============= 4. Średnia prędkość wiatru godzinowo ==============\n\n');
fprintf(fid, '---------------------------\n');
fprintf(fid, 'Godzina | Średnia prędkość\n');
fprintf(fid, '---------------------------\n');
for g = 1:24
    fprintf(fid, '%7d | %.2f km/h\n', g - 1, srednia_wiatru_godziny(g));
end
fprintf(fid, '---------------------------\n');
fprintf(fid, '\nGodzina z najsilniejszym średnim wiatrem: Godzina %d, Średnia prędkość: %.2f km/h\n\n\n', max_wiatr_godzina, max_srednia_wiatru);

% --- Zapis sekcji 5: Analiza sum opadów i ciągów dni z opadami ---
fprintf(fid, '============ 5. Analiza sum opadów i ciągów dni z opadami ============\n\n');
fprintf(fid, "--- Suma opadów dla poszczególnych dni ---\n");
fprintf(fid, '------------------------------------------------------\n');
fprintf(fid, 'Dzień | Suma opadów [mm] | Obserwacje z opadami [%%]\n');
fprintf(fid, '------------------------------------------------------\n');
for dzien = 1:liczba_dni
    % Obliczenia procentu jak w sekcji 5 (można by zapisać wcześniej)
    indeksy_dnia = (dzien - 1) * 24 + 1 : dzien * 24;
    opady_dnia = opady(indeksy_dnia);
    liczba_opadow_dzien = sum(opady_dnia > 0);
    if liczba_opadow_dzien > 0
        procent_opadow_dzien = (liczba_opadow_dzien / 24) * 100;
    else
        procent_opadow_dzien = 0.00;
    end
    fprintf(fid, '%5d | %16.2f | %22.2f%%\n', dzien, suma_opadow_dziennych(dzien), procent_opadow_dzien);
end
fprintf(fid, '------------------------------------------------------\n\n');

fprintf(fid, "--- Analiza najdłuższych okresów opadów ---\n");
fprintf(fid, "-------------------------------------------------------------\n");
fprintf(fid, "%-28s | %-14s | %-10s | %-6s\n", "Rodzaj opadów", "Długość okresu", "Początek", "Koniec");
fprintf(fid, "-------------------------------------------------------------\n");
fprintf(fid, "%-27s | %10d dni | %9d | %5d\n",
        "Jakiekolwiek opady (>0 mm)", max_okres_z_opadami, poczatek_max_okresu_z_opadami, koniec_max_okresu_z_opadami);
fprintf(fid, "%-27s | %10d dni | %9d | %5d\n",
        "Opad > 1 mm", max_okres_z_opadami_znaczacymi, poczatek_max_okresu_z_opadami_znaczacymi, koniec_max_okresu_z_opadami_znaczacymi);
fprintf(fid, "-------------------------------------------------------------\n\n\n");

% --- Zapis sekcji 6: Prawdopodobieństwo opadów o danej godzinie ---
fprintf(fid, '======= 6. Prawdopodobieństwo opadów o danej godzinie ==========\n\n');
fprintf(fid, "----------------------------------------------------\n");
fprintf(fid, "Godzina | Liczba dni z opadami | Prawdopodobieństwo\n");
fprintf(fid, "----------------------------------------------------\n");
for godz_idx = 1:24
    fprintf(fid, "%7d | %20d | %15.4f\n",
            godz_idx - 1, liczba_dni_z_opadami_o_godzinie(godz_idx), prawdopodobienstwo_opadow_godzinowe(godz_idx));
end
fprintf(fid, "----------------------------------------------------\n\n\n");

% --- Zapis sekcji 7: Analiza współwystępowania opadów i wiatru ---
fprintf(fid, '============ 7. Analiza współwystępowania opadów i wiatru ============\n\n');
fprintf(fid, "---------------------------------------------------------------------\n");
fprintf(fid, "Przypadek                      | Liczba obserwacji | Procent [%%]\n");
fprintf(fid, "---------------------------------------------------------------------\n");
fprintf(fid, "a) bez opadów i bez wiatru     | %17d | %10.2f\n", liczba_bez_opadow_bez_wiatru, procent_a);
fprintf(fid, "b) z opadami i bez wiatru      | %17d | %10.2f\n", liczba_z_opadami_bez_wiatru, procent_b);
fprintf(fid, "c) bez opadów, ale z wiatrem   | %17d | %10.2f\n", liczba_bez_opadow_z_wiatrem, procent_c);
fprintf(fid, "d) z opadami oraz wiatrem      | %17d | %10.2f\n", liczba_z_opadami_z_wiatrem, procent_d);
fprintf(fid, "---------------------------------------------------------------------\n");
fprintf(fid, "SUMA                           | %17d | %10.2f\n", suma_kontrolna_obserwacji, 100.0);
fprintf(fid, "---------------------------------------------------------------------\n\n\n");


% --- Zapis sekcji 8: Analiza godzinowych przyrostów temperatury ---
fprintf(fid, '============== 8. Analiza godzinowych przyrostów temperatury ==============\n\n');
fprintf(fid, "-------------------------------------------------------------------------------\n");
fprintf(fid, "Godzina | Średni przyrost | Odchylenie std. | Min. przyrost | Maks. przyrost\n");
fprintf(fid, "-------------------------------------------------------------------------------\n");
for godz_idx = 1:24
    fprintf(fid, "%7d | %15.2f | %15.2f | %13.2f | %14.2f\n",
            godz_idx - 1, srednie_przyrosty_godzinowe(godz_idx), odchylenia_std_przyrostow(godz_idx),
            min_przyrosty_godzinowe(godz_idx), max_przyrosty_godzinowe(godz_idx));
end
fprintf(fid, "-------------------------------------------------------------------------------\n\n\n");

% Zamyka plik wynikowy.
fclose(fid);

% Wyświetla komunikat o pomyślnym zapisaniu wyników.
fprintf('\nWyniki analizy zostały zapisane do pliku: %s\n', plik_wynikowy);

% Koniec skryptu
