# Test für CICD 

      # Cache pip dependencies
      - name: Cache pip dependencies
        uses: actions/cache@v3
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
          restore-keys: |
            ${{ runner.os }}-pip-

      # Install dependencies
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y sysbench
          python -m pip install --upgrade pip
          pip install -r requirements.txt